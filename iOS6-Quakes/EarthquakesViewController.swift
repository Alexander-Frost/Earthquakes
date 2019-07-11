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

        quakeFetcher.fetchQuakes { (quakes, error) in
            if let quakes = quakes {
                print("It's alive! \(quakes.count)")
            }
        }
        
        
    }


}

