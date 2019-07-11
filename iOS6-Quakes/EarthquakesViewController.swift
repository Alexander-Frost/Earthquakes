//
//  ViewController.swift
//  iOS6-Quakes
//
//  Created by Alex on 7/11/19.
//  Copyright © 2019 Alex. All rights reserved.
//

import UIKit
import MapKit

class EarthquakesViewController: UIViewController {
    private lazy var quakeFetcher = QuakeFetcher()
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "QuakeAnnotationView")
        
        let mapCenter = CLLocationCoordinate2D(latitude: 37.79425, longitude: -122.403528) //SF
        let span = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        let region = MKCoordinateRegion(center: mapCenter, span: span)
        mapView.setRegion(region, animated: false)
        
        fetchQuakes()
    }
    
    private func fetchQuakes() {
        quakeFetcher.fetchQuakes { (quakes, error) in
            
            if let error = error {
                print("There was an error: \(error)")
                return
            }
            
            guard let quakes = quakes else {return}
            print("It's alive! \(quakes.count)")
            
            DispatchQueue.main.async {
                self.mapView.addAnnotations(quakes)
            }
        }
    }


}

extension EarthquakesViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Create an annotation view
        
        // Switch statement if checking more than earthquakes
        guard let quake = annotation as? Quake else {return nil}
        
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "QuakeAnnotationView", for: annotation) as! MKMarkerAnnotationView
        
        
        annotationView.glyphImage = UIImage(named: "QuakeIcon")
        annotationView.glyphTintColor = .white // glyph color using Template vector image
        annotationView.markerTintColor = .blue // background color
        
        annotationView.canShowCallout = true
        
        let detailView = QuakeDetailView(frame: .zero) // self-sizing
        detailView.quake = quake
        annotationView.detailCalloutAccessoryView = detailView // annotation view
        
        // Set color of marker based on severity of earthquake
        if quake.properties.mag > 7 {
            annotationView.markerTintColor = .red
        } else if quake.properties.mag > 3 {
            annotationView.markerTintColor = .orange
        }
        
        
        return annotationView
    }
}
