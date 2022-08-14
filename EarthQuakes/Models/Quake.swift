import Foundation
import CoreLocation
import MapKit

/// CLLocationCoordinate2D does not auto conform to Encodable so using Decodable instead of Codable
final class Quake: NSObject, Decodable, MKAnnotation {
    let properties: Properties
    let geometry: Geometry
    
    var coordinate: CLLocationCoordinate2D {
        return geometry.location
    }
    
    var title: String? {
        return properties.place
    }
    
    var subtitle: String? {
        return "\(properties.time)"
    }
    
    struct Properties: Codable {
        let mag: Double
        let place: String?
        let time: Date
        let url: String?
    }
    
    struct Geometry: Decodable {
        let location: CLLocationCoordinate2D
        
        enum GeometryCodingKeys: String, CodingKey {
            case coordinates
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: GeometryCodingKeys.self)
            var coordinatesContainer = try container.nestedUnkeyedContainer(forKey: .coordinates)
            
            let longitude = try coordinatesContainer.decode(Double.self)
            let latitude = try coordinatesContainer.decode(Double.self)
            location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }
}

struct QuakeResults: Decodable {
    let features: [Quake]
}


