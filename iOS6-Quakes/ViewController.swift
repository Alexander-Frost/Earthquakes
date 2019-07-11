//
//  ViewController.swift
//  iOS6-Quakes
//
//  Created by Alex on 7/11/19.
//  Copyright © 2019 Alex. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    private lazy var quakeFetcher = QuakeFetcher()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        quakeFetcher.fetchQuakes { (quakes, error) in
            
            print("It's alive!")
        }
        
        
    }


}

