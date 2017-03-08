//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by VICTOR ASSELTA on 3/7/17.
//  Copyright © 2017 TomTheToad. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    // IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    
    // Fields
    var previousLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkForPreviousMapLocation()
        setMapViewLocation()
    }
    
    func checkForPreviousMapLocation() {
        let previousLatitude = UserDefaults.standard.double(forKey: "latitude")
        let previousLongitude = UserDefaults.standard.double(forKey: "longitude")
        
        print("returned location = lat:\(previousLatitude), long\(previousLongitude)")
        
        previousLocation = CLLocation(latitude: previousLatitude, longitude: previousLongitude)
    }
    
    func setMapViewLocation() {
        let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        let center = previousLocation?.coordinate
        let region = MKCoordinateRegion(center: center!, span: span)
        mapView.setRegion(region, animated: true)
        
    }


}
