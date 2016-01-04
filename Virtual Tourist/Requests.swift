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
    let photoBatchSize: Int = 11
    
    
    //
    // Make the request for search by latitude and longitude
    //
    func requestSearch(urlToCall urlToCall: String, pin: Pin!, greaterID: Int!, controller: UIViewController, contextManaged: NSManagedObjectContext, completionHandler:(result: AnyObject!, error: String?) -> Void) -> NSURLSessionDataTask  {
        let url: NSURL = NSURL(string: urlToCall)!
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = VTConstants.POST_METHOD
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
            if let data = data {
                do {
                    let jsonResult: NSDictionary? = try NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers) as? NSDictionary
                    self.requestPhoto(jsonResult!, itemsCount: jsonResult!.count, pin: pin, greaterID: greaterID , contextManaged: contextManaged, completionHandler: { (result, error) -> Void in
                        if let _ = result {
                            completionHandler(result: result, error: nil)
                        } else {
                            completionHandler(result: nil, error: error)
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
    
    //
    // Return the PhotoResult populated
    //
    // numberOfPics isn't been used at moment.
    //
    func requestPhoto(photos: AnyObject, itemsCount: Int!, pin: Pin!, greaterID: Int!, contextManaged: NSManagedObjectContext, completionHandler:(result: [Photo]?, error: String?)-> Void) {
        let jsonPhotos: [String : AnyObject] = photos["photos"] as! [String : AnyObject]
        let arrayDictionaryPhoto: [[String : AnyObject]] = jsonPhotos["photo"] as! [[String : AnyObject]]
        
        if (arrayDictionaryPhoto.count > 0) {
            var photosArray: [Photo] = [Photo]()
            let urlHelper: UrlHelper = UrlHelper()
            let limitNumberOfPics: Int = greaterID + photoBatchSize
            for photoIndex in greaterID...limitNumberOfPics {
                let photoObj: PhotoComplete = urlHelper.populatePhoto(arrayDictionaryPhoto[photoIndex])
                let urlToCall: String = urlHelper.assembleUrlToLoadImageFromSearch(photoObj)
                
                let url: NSURL = NSURL(string: urlToCall)!
                if let imageData = NSData(contentsOfURL: url) {
                    let imageTemp: UIImage? = UIImage(data: imageData)!
                    
                    if let _ = imageTemp {
                        let tempId: Int = photoIndex + 1
                        print("ID : \(tempId)")
                        let dictionary: [String: AnyObject] = [
                            Photo.Keys.ID : tempId,
                            Photo.Keys.photo : String("\(photoObj.id!)_\(photoObj.secret!).jpg")
                        ]
                        
                        print("\(photoObj.id!)_\(photoObj.secret!).jpg")
                        let tempPhoto: Photo = Photo(photoDictionary: dictionary, context: contextManaged)
                        tempPhoto.position = pin
                        tempPhoto.posterImage = imageTemp
                        
                        photosArray.append(tempPhoto)
                    }
                }
            }
            CoreDataStackManager.sharedInstance().saveContext()
            completionHandler(result: photosArray, error: nil)
        } else {
            completionHandler(result: nil, error: "No result Found!")
            print("No Result Found")
        }
        
    }
}