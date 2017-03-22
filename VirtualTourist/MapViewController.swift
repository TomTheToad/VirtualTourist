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

    // Fields
    let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.handleLongPress(_:)))
    
    // IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    
    // Fields
    var previousLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // mapView delegate
        mapView.delegate = self
        
        // Check UserDefaults for previous location
        checkForPreviousMapLocation()
        
        // Set starting location
        setMapViewLocation()
        
        // Test functions below
        dropTestPin(latitude: (previousLocation?.coordinate.latitude)!, longitude: (previousLocation?.coordinate.longitude)!)
        
        longPressRecognizer.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPressRecognizer)
    }

    
    func checkForPreviousMapLocation() {
        let previousLatitude = UserDefaults.standard.double(forKey: "latitude")
        let previousLongitude = UserDefaults.standard.double(forKey: "longitude")
        
        print("returned location = lat:\(previousLatitude), long\(previousLongitude)")
        
        previousLocation = CLLocation(latitude: previousLatitude, longitude: previousLongitude)
    }
    
    // Configure mapView
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.orange
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    func setMapViewLocation() {
        let regionRadius: CLLocationDistance = 10000
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance((previousLocation?.coordinate)!, regionRadius, regionRadius)
        
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    
    // Configure User Pin drop
    func handleLongPress(_ gestureRecognizer : UIGestureRecognizer) {
        if gestureRecognizer.state != .began { return }
        let touchPoint = gestureRecognizer.location(in: mapView)
        let touchMapCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let thisAnnotation = MKPointAnnotation()
        thisAnnotation.coordinate = touchMapCoordinate
        thisAnnotation.title = "test pin drop"
        
        mapView.addAnnotation(thisAnnotation)
    }
    
    
    // Allow mapView location bubble click through to give student mediaURL in safari.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            presentCollectionView()
        }
    }
    
    // Test functions
    func progCollectionViewTest() {
        // test sub view
        let collectionViewController = CollectionViewController()
        
        let collectionViewFrame = CGRect(x: 260, y: 340, width: 200, height: 250)
        
        // Programmatically or use xib?
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 111, height: 111)
        
        let collectionView = UICollectionView(frame: collectionViewFrame, collectionViewLayout: layout)
        collectionView.delegate = collectionViewController
        collectionView.dataSource = collectionViewController
        collectionView.backgroundColor = UIColor.blue
        
        view.addSubview(collectionView)
        
        // Do in MapViewController?
        // colView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
    }
    
    
    func dropTestPin(latitude: Double, longitude: Double) {
       
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        let annotation = MKPointAnnotation()
     
        annotation.coordinate = location
        annotation.title = "Test Pin"
        
        mapView.addAnnotation(annotation)
    }
    
    
    // Collection View
    func presentCollectionView() {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "CollectionView") else {
            print("MESSAGE: Failed to instantiate collection view controller")
            return
        }
        
        present(controller, animated: false, completion: {
            print("MESSAGE: CollectionView Called")
        })
    }

}

extension MapViewController {
    
}
