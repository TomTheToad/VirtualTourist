//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by VICTOR ASSELTA on 3/7/17.
//  Copyright © 2017 TomTheToad. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {
    
    // Fields
    var locationManager = CLLocationManager()
    var doDeletePins = false
    let coreData = CoreDataController()
    
    // IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Configure navigationView
        navigationItem.title = "Virtual Tourist"
        HideToolBar()
        
        // Clears selected pin(s)
        deselectAllPins()
        
        // Preload pins
        addAnnotationsFromMemory()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Add bottom tool bar
        addToolBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Configure mapView
        configureMapView()

        // Set starting location
        setMapViewLocationUserDefaults()
        
        // Configure core location
        configureCoreLocation()

    }
    
    /*** UI ***/
    func configureMapView() {
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.isRotateEnabled = false
        mapView.addGestureRecognizer(fetchLongPressRecognizer())
    }
    
    func configureCoreLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
    }
    
    func fetchLongPressRecognizer() -> UILongPressGestureRecognizer {
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.addAnnotation(_:)))
        longPressRecognizer.isEnabled = true
        return longPressRecognizer
    }
    
    func addToolBar() {
        // todo: use default edit button and didSet editing instead
        
        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(ShowToolBar(sender:)))
        
        navigationItem.rightBarButtonItem = editButton
        
        let toolBarFlexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let toolBarButtonLabel = UIBarButtonItem(title: "Select Pins to Delete", style: .plain, target: self, action: nil)
        toolBarButtonLabel.tintColor = UIColor.white
        navigationController?.toolbar.barTintColor = UIColor.red
        toolbarItems = [toolBarFlexibleSpace, toolBarButtonLabel, toolBarFlexibleSpace]
    }
    
    func ShowToolBar(sender: UIBarButtonItem) {
        if navigationController?.toolbar.isHidden != false {
            navigationController?.setToolbarHidden(false, animated: true)
            doDeletePins = true
        } else {
            navigationController?.setToolbarHidden(true, animated: true)
            doDeletePins = false
        }
    }
    
    func HideToolBar() {
        navigationController?.setToolbarHidden(true, animated: false)
        doDeletePins = false
    }
    
    /*** MapView ***/
    // todo: add region
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // saveLocationToCoreData(location: mapView.centerCoordinate)
        saveLocationToUserDefaults(location: mapView.centerCoordinate)
        print("MESSAGE: mapView region did change")
    }
    
    // Configure mapView
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = UIColor.orange
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        guard let location = view.annotation?.coordinate else {
            print("Location Missing")
            return
        }
        
        guard let pin = coreData.fetchPin(location: location) else {
            print("Pin not returned from CoreData")
            return
        }
        
        if !doDeletePins {
            DispatchQueue.main.async(execute: { ()-> Void in
                self.presentDetailView(pin: pin)
            })
        } else {
            guard let annotation = view.annotation else {
                print("Warning: Cannot delete view. View not found")
                return
            }

            coreData.deletePin(pin: pin)
            coreData.saveChanges()
            mapView.removeAnnotation(annotation)
        }
    }
    
    func setMapViewLocationUserDefaults() {
        let regionRadius: CLLocationDistance = 15000
        let previousLocation: CLLocationCoordinate2D? = {
            
            guard let lat = UserDefaults.standard.object(forKey: "latitude") as? CLLocationDegrees else {
                return nil
            }
            guard let long = UserDefaults.standard.object(forKey: "longitude") as? CLLocationDegrees else {
                return nil
            }
            return CLLocationCoordinate2D(latitude: lat, longitude: long)
        }()
        
        if let location = previousLocation {
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(location, regionRadius, regionRadius)
            mapView.setRegion(coordinateRegion, animated: true)
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    func addAnnotation(_ gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == .began {
            HideToolBar()
            let touchPoint = gestureRecognizer.location(in: mapView)
            let newCoords = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = newCoords
            annotation.title = "User Added Point"
            // mapView.addAnnotation(annotation)
            activityIndicator.startAnimating()
            
            createNewPin(location: newCoords, errorController: { isSuccess, error in
                DispatchQueue.main.async(execute: { ()-> Void in
                    self.activityIndicator.stopAnimating()
                    if isSuccess {
                        self.mapView.addAnnotation(annotation)
                    } else {
                        guard let thisError = error else {
                            let alert = OKAlertGenerator(alertMessage: "Sorry. I can't find images for that location. Error: Unknown")
                            self.present(alert.getAlertToPresent(), animated: false, completion: nil)
                            return
                        }
                        
                        let alert = OKAlertGenerator(alertMessage: "Sorry. I can't find images for that location. Error: \(thisError)")
                            self.present(alert.getAlertToPresent(), animated: false, completion: nil)
                    }
                })
            })
        }
    }
    
    func hideActivityIndicator() {
        activityIndicator.stopAnimating()
    }
    
    func addAnnotationsFromMemory() {

        guard let pins = coreData.fetchPins() else {
            return
        }
        
        for pin in pins {
            let annotation = MKPointAnnotation()
            annotation.coordinate = (CLLocationCoordinate2DMake(pin.latitude, pin.longitude))
            if doesMapViewContainAnnotation(annotation: annotation) == false {
                mapView.addAnnotation(annotation)
            }
        }
    }
    
    func doesMapViewContainAnnotation(annotation: MKAnnotation) -> Bool {
        if mapView.annotations.isEmpty {
            return false
        }
        
        for item in mapView.annotations {
            if item.coordinate.latitude == annotation.coordinate.latitude, item.coordinate.longitude == annotation.coordinate.longitude {
                return true
            }
        }
        
        return false
    }
    
    // helper
    // Make sure any pins are deselected
    func deselectAllPins() {
        let selectedAnnotations = mapView.selectedAnnotations
        for pinAnnotation in selectedAnnotations {
            mapView.deselectAnnotation(pinAnnotation, animated: false)
        }
    }
}

extension MapViewController {
    
    func createNewPin(location: CLLocationCoordinate2D, errorController: @escaping (_ isSuccess: Bool,_ error: Error?) -> Void) {
        let flikr = FlikrAPIController()
        
        do {
            try flikr.getImageArray(location: location, completionHander: { error, data in
                
                if error == nil {
                    // handle error
                    if let error = error {
                        errorController(false, error)
                    } else {
                        if let images = data {
                            self.coreData.createPin(dictionary: images, location: location)
                        } else {
                            print("ERROR: missing returned urls")
                        }
                    }
                }
            })
            errorController(true, nil)
        } catch {
            errorController(false, CoreDataErrors.FailedToAddPin)
        }
    }
    
}

extension MapViewController {
    
    func presentDetailView(pin: Pin) {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "DetailView") as? DetailViewController else {
            print("MESSAGE: Failed to instantiate collection view controller")
            return
        }
        
        controller.pin = pin
        
        let backItem = UIBarButtonItem()
        backItem.title = "OK"
        
        navigationItem.backBarButtonItem = backItem
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension MapViewController {
    func saveLocationToUserDefaults(location: CLLocationCoordinate2D) {
        UserDefaults.standard.setValuesForKeys(["latitude": location.latitude])
        UserDefaults.standard.setValuesForKeys(["longitude": location.longitude])
        UserDefaults.standard.synchronize()
    }
}

extension MapViewController {
    enum MapViewControllerError: Error {
        case previousLocationMissing
    }
}
