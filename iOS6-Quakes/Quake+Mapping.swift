//
//  Quake+Mapping.swift
//  iOS6-Quakes
//
//  Created by Alex on 7/11/19.
//  Copyright © 2019 Alex. All rights reserved.
//

import Foundation
import MapKit

extension Quake: MKAnnotation {
    var coordinate: CLLocationCoordinate2D {return geometry.location}
    var title: String? {return properties.place}
    var subtitle: String? {return "\(properties.time)"}
}
