//
//  FlickrAPIController.swift
//  VirtualTourist
//
//  Created by VICTOR ASSELTA on 2/27/17.
//  Copyright © 2017 TomTheToad. All rights reserved.
//

import Foundation

class FlickrAPIController {
    
    // Fields
    let responseCheck = URLResponseCheck()
    
    // Flickr application key
    let key = "f3faa7b346140c4f70790665703a4247"
    let method = "flickr.photos.search"
    let session = URLSession(configuration: .ephemeral)
    let baseURLString = "https://api.flickr.com/services/rest/"
    
    
    // Custom errors for this API
    enum FlickrErrors: Error {
        case ApplicationError(msg: String)
        case NetworkRequestError(returnError: Error)
        case XMLParseError
    }
    
    
    /* bbox (Optional)
    A comma-delimited list of 4 values defining the Bounding Box of the area that will be searched.
    
    The 4 values represent the bottom-left corner of the box and the top-right corner, minimum_longitude, minimum_latitude, maximum_longitude, maximum_latitude
    */
 
    // flickr.photos.search
    // lat, lon, radius, accuracy, safe_search, unit, radius_units, page, per_page
    // return a dictionary
    func getPhotosIDList(latitude: String, longitude: String, completionHander: @escaping (Error?, [String]?) -> Void) throws {
        
        let url = baseURLString + "?" + "method=\(method)&api_key=\(key)&format=json&nojsoncallback=1&lat=\(latitude)&lon=\(longitude)&radius=5&radius_units=mi&accuracy=11&safe_search=2&page=1&per_page=21"
        
        let request = URLRequest(url: URL(string: url)!)
        
        let task = session.dataTask(with: request, completionHandler: {
            (data, response, error) in
            
            if let thisResponse = response {
                let responseCheck = self.responseCheck.checkReponse(thisResponse)
                if responseCheck.0 != true {
                    // todo: create custom errors
                    print("NETWORK ERROR: \(responseCheck.1)")
                    return
                }
            }
            
            if let thisError = error {
                print("ERROR: \(thisError)")
            }
            
            guard let thisData = data else {
                // todo: add response check
                if let error = error  {
                    completionHander(FlickrErrors.NetworkRequestError(returnError: error), nil)
                    return
                } else {
                    guard let thisResponse = response else {
                        completionHander(FlickrErrors.ApplicationError(msg: "Unknown Error"), nil)
                        return
                    }
                    completionHander(FlickrErrors.ApplicationError(msg: (thisResponse.description)), nil)
                    return
                }
            }
            
            print("thisData is emtpy?: \(thisData.isEmpty)")
            
            let result = NSString(data: thisData, encoding: String.Encoding.utf8.rawValue)
            print("result: \(result)")
            
            var parsedResults: NSDictionary?

            do {
                parsedResults = try JSONSerialization.jsonObject(with: thisData, options: .allowFragments) as? NSDictionary
            } catch {
                print("Printed on the label: DOES NOT WORK!")
            }

            print("parsedResults: \(parsedResults)")

            let photos = parsedResults!.value(forKeyPath: "photos.photo") as! [NSDictionary]
            // print("photos: \(photos.allKeys)")
            
            print("photos: \(photos)")
            
            let urls = self.FlickrDictToURL(dictionary: photos)
            
            for item in urls {
                print(item)
            }
            
            completionHander(nil, urls)
              
        })
        
        task.resume()
        
    }
    
    func FlickrDictToURL(dictionary: [NSDictionary]) -> [String] {
        /*
        https://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}.jpg
        or
        https://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}_[mstzb].jpg
        or
        https://farm{farm-id}.staticflickr.com/{server-id}/{id}_{o-secret}_o.(jpg|gif|png)
         */
        
        var urlsArray = [String]()
        
        for image in dictionary {
            // change all to guard
            let farmID = image.value(forKey: "farm")
            let serverID = image.value(forKey: "server")
            let secret = image.value(forKey: "secret")
            let id = image.value(forKey: "id")
            let url = "https://farm\(farmID!).staticflickr.com/\(serverID!)/\(id!)_\(secret!).jpg"
            urlsArray.append(url)
        }
        
        return urlsArray
    }
    
    func getPhotosFetchedResultsController() {
        // todo: add this functionality
    }

}
