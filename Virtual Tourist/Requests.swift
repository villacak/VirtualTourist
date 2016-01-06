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
    
    // Set to 11 as it starts from zero, so this give me 12 pics!
//    let photoBatchSize: Int = 11
    
    
    //
    // Make the request for search by latitude and longitude
    //
    func requestSearch(urlToCall urlToCall: String, pin: Pin!, greaterID: Int!, controller: UIViewController, contextManaged: NSManagedObjectContext, completionHandler:(result: NSDictionary?, error: String?) -> Void) -> NSURLSessionDataTask  {
        let url: NSURL = NSURL(string: urlToCall)!
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = VTConstants.POST_METHOD
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
            if let data = data {
                do {
                    let jsonResult: NSDictionary? = try NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers) as? NSDictionary
                    completionHandler(result: jsonResult, error: nil)
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
    
    //
    // Return the PhotoResult populated
    //
    //
    func requestPhoto(photoObj: PhotoComplete?, pin: Pin!, photoIndex: Int!, contextManaged: NSManagedObjectContext, completionHandler:(result: Photo?, error: String?)-> Void) {
        var tempPhoto: Photo?
        
        if let _ = photoObj {
            let urlHelper: UrlHelper = UrlHelper()
            let urlToCall: String = urlHelper.assembleUrlToLoadImageFromSearch(photoObj!)
            
            let url: NSURL = NSURL(string: urlToCall)!
            if let imageData = NSData(contentsOfURL: url) {
                let imageTemp: UIImage? = UIImage(data: imageData)!
                
                if let _ = imageTemp {
                    let tempId: Int = photoIndex + 1
                    print("--- ID : \(tempId)")
                    let dictionary: [String: AnyObject] = [
                        Photo.Keys.ID : tempId,
                        Photo.Keys.photo : String("\(photoObj!.id!)_\(photoObj!.secret!).jpg")
                    ]
                    
                    print("\(photoObj!.id!)_\(photoObj!.secret!).jpg")
                    tempPhoto = Photo(photoDictionary: dictionary, context: contextManaged)
                    tempPhoto!.position = pin
                    tempPhoto!.posterImage = imageTemp
                }
            }
            CoreDataStackManager.sharedInstance().saveContext()
            completionHandler(result: tempPhoto, error: nil)
        } else {
            completionHandler(result: nil, error: "No result Found!")
            print("No Result Found")
        }
    }
}