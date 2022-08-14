import UIKit
import MapKit

final class ViewController: UIViewController {
    
    // MARK: - Properties
    
    private var earthquakes: [Quake] = [] {
        didSet {
            mapView.addAnnotations(earthquakes)
            tableView.reloadData()
        }
    }
    
    // MARK: - Instances
    
    /// Using MVC instead of MVVM b/c we don't want to overcomplicate the code for something so simple
    private let networkController = NetworkController()
    
    // MARK: - Elements
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .blue
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(QuakeTableViewCell.self, forCellReuseIdentifier: QuakeTableViewCell.reuseId)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.delegate = self
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "QuakeAnnotationView")
        
        let mapCenter = CLLocationCoordinate2D(latitude: 37.79425, longitude: -122.403528) /// San Francisco
        let span = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        let region = MKCoordinateRegion(center: mapCenter, span: span)
        mapView.setRegion(region, animated: false)
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    // MARK: - Actions
    
    @objc
    private func pullToRefresh() {
        loadData()
        tableView.refreshControl?.endRefreshing()
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    // MARK: - Setup UI
    
    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(mapView)
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.topAnchor.constraint(equalTo: mapView.bottomAnchor),

            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.heightAnchor.constraint(equalToConstant: 300)
        ])
        
        setupPullToRefresh()
    }
    
    private func setupPullToRefresh() {
        let refreshControl = UIRefreshControl(frame: .zero)
        refreshControl.tintColor = .gray
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    // MARK: - Operations
    
    private func loadData() {
        networkController.fetchQuakes { [weak self] result in
            switch result {
            case .success(let earthquakes):
                DispatchQueue.main.async {
                    self?.earthquakes = earthquakes
                }
                
            case .failure(let error):
                print("There was an error: \(error.localizedDescription)")
            }
        }
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: QuakeTableViewCell.reuseId, for: indexPath) as? QuakeTableViewCell else {
            return UITableViewCell()
        }
        let earthquake = earthquakes[indexPath.row]
        cell.loadData(title: earthquake.title, subtitle: earthquake.subtitle, subtitleTwo: "Magnitude: \(earthquake.properties.mag)")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = EarthquakeDetailViewController()
        let earthquake = earthquakes[indexPath.row]
        vc.website = earthquake.properties.url
        navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return earthquakes.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return QuakeTableViewCell.cellHeight
    }
    
    
    
}

extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? { /// Try clicking on a marker in the app!
        guard let earthquake = annotation as? Quake else { return nil }
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "QuakeAnnotationView", for: annotation) as! MKMarkerAnnotationView
        annotationView.glyphImage = UIImage(named: "QuakeIcon")
        annotationView.glyphTintColor = .white
        annotationView.markerTintColor = .blue
        annotationView.canShowCallout = true
        let detailView = AnnotationView(frame: .zero)
        detailView.earthquake = earthquake
        annotationView.detailCalloutAccessoryView = detailView
        
        /// Set color of marker based on severity of earthquake
        if earthquake.properties.mag > 6 {
            annotationView.markerTintColor = .red
        } else if earthquake.properties.mag > 3 {
            annotationView.markerTintColor = .orange
        }
        return annotationView
    }
}
