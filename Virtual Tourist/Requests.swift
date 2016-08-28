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
    func requestSearch(urlToCall: String, pin: Pin!, controller: UIViewController, contextManaged: NSManagedObjectContext, completionHandler:@escaping (_ result: NSDictionary?, _ error: String?) -> Void) -> URLSessionDataTask  {
        let url: URL = URL(string: urlToCall)!
        let request: NSMutableURLRequest = NSMutableURLRequest(url: url)
        request.httpMethod = VTConstants.POST_METHOD
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            if let data = data {
                do {
                    let jsonResult: NSDictionary? = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
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
    func requestPhoto(_ photoObj: PhotoComplete?, pin: Pin!, photoIndex: Int!, contextManaged: NSManagedObjectContext, completionHandler:(_ result: Photo?, _ error: String?)-> Void) {
        var tempPhoto: Photo?
        
        if let _ = photoObj {
            let urlHelper: UrlHelper = UrlHelper()
            let urlToCall: String = urlHelper.assembleUrlToLoadImageFromSearch(photoObj!)
            
            let url: URL = URL(string: urlToCall)!
            if let imageData = try? Data(contentsOf: url) {
                let imageTemp: UIImage? = UIImage(data: imageData)!
                
                if let _ = imageTemp {
                    let tempId: Int = photoIndex + 1
                    print("--- ID : \(tempId)")
                    let dictionary: [String: AnyObject] = [
                        Photo.Keys.ID : tempId as AnyObject,
                        Photo.Keys.photo : String("\(photoObj!.id!)_\(photoObj!.secret!).jpg") as AnyObject
                    ]
                    
                    print("\(photoObj!.id!)_\(photoObj!.secret!).jpg")
                    tempPhoto = Photo(photoDictionary: dictionary, context: contextManaged)
                    tempPhoto!.position = pin
                    tempPhoto!.posterImage = imageTemp
                }
            }
            CoreDataStackManager.sharedInstance().saveContext()
            completionHandler(tempPhoto, nil)
        } else {
            completionHandler(nil, "No result Found!")
            print("No Result Found")
        }
    }
}
