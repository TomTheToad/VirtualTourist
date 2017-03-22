//
//  DetailViewController.swift
//  VirtualTourist
//
//  Created by VICTOR ASSELTA on 3/22/17.
//  Copyright © 2017 TomTheToad. All rights reserved.
//

import UIKit
import MapKit

class DetailViewController: UIViewController {
    
    // Fields
    var receivedMapLocation: CLLocationCoordinate2D?
    
    // IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure mapView
        mapView.delegate = self
        
        // Configure collectionView
        collectionView!.delegate = self
        collectionView!.dataSource = self
        
    }

}

extension DetailViewController: MKMapViewDelegate {
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        setMapViewLocation()
    }
    
    func setMapViewLocation() {
        let regionRadius: CLLocationDistance = 3000
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(receivedMapLocation!, regionRadius, regionRadius)
        
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
}


extension DetailViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //        let width = collectionView!.frame.width / 3
        //        let layout = UICollectionViewFlowLayout()
        //        layout.itemSize = CGSize(width: width - 3, height: width - 3)
        //        collectionView.collectionViewLayout = layout
        
        let width = collectionView.frame.width / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailCollectionViewCell", for: indexPath) as! CollectionViewCell
        
        // Configure the cell
        cell.backgroundColor = UIColor.green
        cell.textLabel!.text = "\((indexPath as NSIndexPath).row)"
        
        return cell
    }

    
}
