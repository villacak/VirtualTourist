//
//  Requests.swift
//  Virtual Tourist
//
//  Created by Klaus Villaca on 12/29/15.
//  Copyright © 2015 Klaus Villaca. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Requests: NSObject {
    
    //    let photoIndex: Int = 12
    
    //
    // Make the request for search by latitude and longitude
    //
    func requestSearch(urlToCall urlToCall: String, controller: UIViewController, contextManaged: NSManagedObjectContext, completionHandler:(result: AnyObject!, error: String?) -> Void) -> NSURLSessionDataTask  {
        let url: NSURL = NSURL(string: urlToCall)!
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = VTConstants.POST_METHOD
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
            if let data = data {
                do {
                    let jsonResult: NSDictionary? = try NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers) as? NSDictionary
                    self.requestPhoto(jsonResult!, itemsCount: jsonResult!.count, contextManaged: contextManaged, completionHandler: { (result, error) -> Void in
                        if let _ = result {
                            completionHandler(result: result, error: nil)
                        } else {
                            completionHandler(result: nil, error: nil)
                        }
                    })
                } catch let error as NSError {
                    completionHandler(result: nil, error: error.localizedDescription)
                    print("Error 1: \(error.localizedDescription)")
                }
            } else if let error = error {
                completionHandler(result: nil, error: error.localizedDescription)
                print("Error 2: \(error.localizedDescription)")
            }
        })
        task.resume()
        return task
        
    }
    
    
    // Return the PhotoResult populated
    func requestPhoto(photos: AnyObject, itemsCount: Int, contextManaged: NSManagedObjectContext, completionHandler:(result: [Photo]?, error: String?)-> Void) {
        let jsonPhotos: [String : AnyObject] = photos["photos"] as! [String : AnyObject]
        let arrayDictionaryPhoto: [[String : AnyObject]] = jsonPhotos["photo"] as! [[String : AnyObject]]
        
        if (arrayDictionaryPhoto.count > 0) {
            var photosArray: [Photo] = [Photo]()
            let urlHelper: UrlHelper = UrlHelper()
            for photoIndex in 0...11 {
                let photoObj: PhotoComplete = urlHelper.populatePhoto(arrayDictionaryPhoto[photoIndex])
                let urlToCall: String = urlHelper.assembleUrlToLoadImageFromSearch(photoObj)
                
                let url: NSURL = NSURL(string: urlToCall)!
                if let imageData = NSData(contentsOfURL: url) {
                    dispatch_async(dispatch_get_main_queue(), {
                        let imageTemp: UIImage = UIImage(data: imageData)!
                        
                        let dictionary: [String: AnyObject] = [
                            Photo.Keys.ID : photoIndex,
                            Photo.Keys.photo : imageTemp
                        ]
                        
                        let tempPhoto: Photo = Photo(photoDictionary: dictionary, context: contextManaged)
                        photosArray.append(tempPhoto)
                    })
                    
                }
                completionHandler(result: photosArray, error: nil)
            }
        } else {
            completionHandler(result: nil, error: "No result Found!")
            print("No Result Found")
        }
        
    }
}