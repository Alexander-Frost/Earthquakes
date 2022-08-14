import Foundation
import UIKit

final class AnnotationView: UIView {
    
    // MARK: - Properties
    
    var earthquake: Quake? {
        didSet {
            updateUI()
        }
    }
    
    private let dateFormatter: DateFormatter = {
        let result = DateFormatter()
        result.dateStyle = .short
        result.timeStyle = .short
        return result
    }()
    
    private let latLonFormatter: NumberFormatter = {
        let result = NumberFormatter()
        result.numberStyle = .decimal
        result.minimumIntegerDigits = 1
        result.minimumFractionDigits = 2
        result.maximumFractionDigits = 2
        return result
    }()
    
    // MARK: - Elements
    
    private let magnitudeLabel = UILabel()
    private let dateLabel = UILabel()
    private let latitudeLabel = UILabel()
    private let longitudeLabel = UILabel()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        
        let placeDateStackView = UIStackView(arrangedSubviews: [magnitudeLabel, dateLabel])
        placeDateStackView.spacing = UIStackView.spacingUseSystem
        
        let coorStackView = UIStackView(arrangedSubviews: [latitudeLabel, longitudeLabel])
        coorStackView.spacing = UIStackView.spacingUseSystem
        
        stackView.addArrangedSubview(placeDateStackView)
        stackView.addArrangedSubview(coorStackView)
        stackView.axis = .vertical
        stackView.spacing = UIStackView.spacingUseSystem
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        latitudeLabel.setContentHuggingPriority(.defaultLow+1, for: .horizontal)
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalTo: leftAnchor),
            stackView.rightAnchor.constraint(equalTo: rightAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Update UI
    
    private func updateUI() {
        guard let quake = earthquake else { return }
        let magnitude = quake.properties.mag
        magnitudeLabel.text = String(magnitude) + " magnitude"
        dateLabel.text = dateFormatter.string(from: quake.properties.time)
        latitudeLabel.text = "Lat: " + latLonFormatter.string(from: quake.geometry.location.latitude as NSNumber)!
        longitudeLabel.text = "Lon: " + latLonFormatter.string(from: quake.geometry.location.longitude as NSNumber)!
    }
}
