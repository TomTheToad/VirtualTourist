//
//  FlickrAPIController.swift
//  VirtualTourist
//
//  Created by VICTOR ASSELTA on 2/27/17.
//  Copyright © 2017 TomTheToad. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

class FlikrAPIController {
    
    // Fields
    let responseCheck = URLResponseCheck()
    let managedObjectContext: NSManagedObjectContext = {
        return AppDelegate().persistentContainer.viewContext
    }()
    
    // Flickr application key
    let key = "f3faa7b346140c4f70790665703a4247"
    let method = "flickr.photos.search"
    let session = URLSession(configuration: .ephemeral)
    let baseURLString = "https://api.flickr.com/services/rest/"
    
    // Custom errors for this API
    enum FlikrErrors: Error {
        case ApplicationError(msg: String)
        case NetworkRequestError(returnError: Error)
        case URLResponse(response: URLResponse)
        case JSONParseError
    }
    
    
    /* bbox (Optional)
    A comma-delimited list of 4 values defining the Bounding Box of the area that will be searched.
    
    The 4 values represent the bottom-left corner of the box and the top-right corner, minimum_longitude, minimum_latitude, maximum_longitude, maximum_latitude
    */
 
    // flickr.photos.search
    // lat, lon, radius, accuracy, safe_search, unit, radius_units, page, per_page
    // return a dictionary
    
    func getImageArray(location: CLLocationCoordinate2D, completionHander: @escaping (Error?, [NSDictionary]?) -> Void) throws {
        
        let latitude = location.latitude
        let longitude = location.longitude
        
        let page = arc4random_uniform(50)
        print("random page number = \(page)")
        
        let url = baseURLString + "?" + "method=\(method)&api_key=\(key)&format=json&nojsoncallback=1&lat=\(latitude)&lon=\(longitude)&radius=5&radius_units=mi&accuracy=11&safe_search=2&\(page)&per_page=21"
        
        let request = URLRequest(url: URL(string: url)!)
        
        let task = session.dataTask(with: request, completionHandler: {
            (data, response, error) in
            
            if let thisResponse = response {
                let responseCheck = self.responseCheck.checkReponse(thisResponse)
                if responseCheck.0 != true {
                    completionHander(FlikrErrors.URLResponse(response: thisResponse), nil)
                    print("NETWORK ERROR: \(responseCheck.1)")
                    return
                }
            }
            
            if let thisError = error {
                completionHander(thisError, nil)
                print("ERROR: \(thisError)")
            }
            
            guard let thisData = data else {
                if let error = error  {
                    completionHander(FlikrErrors.NetworkRequestError(returnError: error), nil)
                    return
                } else {
                    guard let thisResponse = response else {
                        completionHander(FlikrErrors.ApplicationError(msg: "Unknown Error"), nil)
                        return
                    }
                    completionHander(FlikrErrors.URLResponse(response: thisResponse), nil)
                    return
                }
            }
            
            do {
                let photosDict = try self.ParseJSONToNSDict(JSONData: thisData)
                completionHander(nil, photosDict)
            } catch {
                completionHander(FlikrErrors.JSONParseError, nil)
            }
            
        })
        
        task.resume()
        
    }

    func ParseJSONToNSDict(JSONData: Data) throws -> [NSDictionary] {
        var parsedResults: NSDictionary?
        
        do {
            parsedResults = try JSONSerialization.jsonObject(with: JSONData, options: .allowFragments) as? NSDictionary
        } catch {
            throw FlikrErrors.JSONParseError
        }
        
        if let photos = parsedResults?.value(forKeyPath: "photos.photo") as! [NSDictionary]? {
            return photos
        } else {
            throw FlikrErrors.JSONParseError
        }

    }
    
    func downloadImageFromFlikrURL(url: URL, completionHandler: @escaping (_ data: Data?,_ repsonse: URLResponse?,_ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url, completionHandler: {
            (data, response, error) in
            completionHandler(data, response, error)
        }).resume()
    }
}
