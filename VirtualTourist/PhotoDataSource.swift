//
//  PhotoDataSource.swift
//  VirtualTourist
//
//  Created by VICTOR ASSELTA on 6/18/17.
//  Copyright © 2017 TomTheToad. All rights reserved.
//

import UIKit

class PhotoDataSource: NSObject, UICollectionViewDataSource {
    
    // Dependencies
    let flikr = FlikrAPIController()
    let coreData = CoreDataController()
    
    // Data
    var photos = [Photo]()
    
    var count: Int {
        return photos.count
    }
    
    // Data functions
    func deletePhotos(indexArray: [IndexPath]) {
        for index in indexArray {
            photos.remove(at: index.row)
        }
    }
    
    func replacePhotos(photoArray: [Photo]) {
        photos = photoArray
    }
    
    /// CollectionView Required Functions ///
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailCollectionViewCell", for: indexPath) as! CollectionViewCell
        cell.backgroundColor = .blue
        
        // let photo = resultsController.object(at: indexPath) as Photo
        let photo = photos[indexPath.row]
        
        let url = URL(string: photo.url!)
        
        if let image = photo.image as Data? {
            cell.id = photo.id
            cell.imageView.image = UIImage(data: image)
            cell.activityIndicator.stopAnimating()
        } else {
            
            flikr.downloadImageFromFlikrURL(url: url!, completionHandler: {
                (data, response, error) in
                
                if error == nil {
                    // todo: check for data
                    if let imageData = data {
                        photo.image = NSData(data: imageData)
                        self.coreData.saveChanges()
                    }
                    
                    let photoImage = UIImage(data: data!)
                    DispatchQueue.main.async(execute: { ()-> Void in
                        cell.imageView.image = photoImage
                        cell.activityIndicator.stopAnimating()
                    })
                } else {
                    guard let thisResponse = response else {
                        print("DV: No response")
                        return
                    }
                    
                    print("Response: \(thisResponse)")
                    
                    guard let thisError = error else {
                        print("Error: No error")
                        return
                    }
                    
                    print("Error: \(thisError)")
                }
                
            })
        }
        
        return cell
        
    }

}
