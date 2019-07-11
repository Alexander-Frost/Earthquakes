//
//  Quake.swift
//  iOS6-Quakes
//
//  Created by Alex on 7/11/19.
//  Copyright © 2019 Alex. All rights reserved.
//

import Foundation
import CoreLocation

class Quake: Decodable {
    let properties: Properties
    
    // mag - magnitude
    // place
    // time
    struct Properties: Decodable {
        let mag: Double
        let place: String
        let time: Date
        
        enum PropertiesCodingKeys: String, CodingKey {
            case mag
            case place
            case time
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: PropertiesCodingKeys.self)
            
            mag = (try? container.decode(Double.self, forKey: .mag)) ?? 0
            place = try container.decode(String.self, forKey: .place)
            time = try container.decode(Date.self, forKey: .time)
        }
    }
    
    // latitude
    // longitude
    
    struct Geometry: Decodable {
        let location: CLLocationCoordinate2D
        
        enum GeometryCodingKeys: String, CodingKey {
            case coordinates
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: GeometryCodingKeys.self)
            var coordinatesContainer = try container.nestedUnkeyedContainer(forKey: .coordinates)

//         let longitude = (try? coordinatesContainer.decode(Double.self)) ?? 0
            let longitude = try coordinatesContainer.decode(Double.self)
            let latitude = try coordinatesContainer.decode(Double.self)
            
            location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }
}

struct QuakeResults: Decodable {
    let features: [Quake]
}
