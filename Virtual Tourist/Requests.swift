//
//  Requests.swift
//  Virtual Tourist
//
//  Created by Klaus Villaca on 12/29/15.
//  Copyright © 2015 Klaus Villaca. All rights reserved.
//

import Foundation


class Requests: NSObject {
    
    //
    // Make the request for search by latitude and longitude
    //
    func requestSearch(urlToCall urlToCall: String, completionHandler:(result: AnyObject!, error: String?) -> Void) -> NSURLSessionDataTask  {
        let url: NSURL = NSURL(string: urlToCall)!
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = POST_METHOD
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
            if let data = data {
                do {
                    let jsonResult: NSDictionary? = try NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers) as? NSDictionary
                    self.requestPhoto(jsonResult!, itemsCount: jsonResult!.count, handler: { (result) -> Void in
                        if let _ = result {
                            completionHandler(result: self.photoResultReturn, error: nil)
                        } else {
                            completionHandler(result: nil, error: nil)
                        }
                        
                    })
                } catch let error as NSError {
                    completionHandler(result: nil, error: error.localizedDescription)
                }
            } else if let error = error {
                completionHandler(result: nil, error: error.localizedDescription)
            }
        })
        task.resume()
        return task
        
    }
    
    //
    // Function to call the service and populate data when response return
    //
    func makeRESTCallAndGetResponse(urlToCall: String) {
        let helperObject: UrlHelper = UrlHelper()
        var photoResult: PhotoResult!
        // Change to false the line bellow and enable the second line to have option to select a picture
        // instead random
        helperObject.isRandom = true
        //        urlHelper.photoIndex = 1
        helperObject.requestSearch(urlToCall, handler: { (result) -> Void in
            if let photoResultTemp = result {
                photoResult = photoResultTemp
                self.imageLoaded.image = photoResult.photoImage
                self.imageLoaded.contentMode = UIViewContentMode.ScaleAspectFit
                self.detailsLabel.text = photoResult.photoTitle.text
            } else {
                self.imageLoaded.image = nil
                self.detailsLabel.text = "No data"
                Utils().noResultsAlert(self)
            }
        })
    }
    
    
    // Return the PhotoResult populated
    func requestPhoto(photos: AnyObject, itemsCount: Int, handler:(result: Bool?)-> Void) {
        if (photoIndex == 0 || (photoIndex >= 1 && photoIndex <= itemsCount)) {
            let jsonPhotos: [String : AnyObject] = photos["photos"] as! [String : AnyObject]
            let arrayDictionaryPhoto: [[String : AnyObject]] = jsonPhotos["photo"] as! [[String : AnyObject]]
            
            if (arrayDictionaryPhoto.count > 0) {
                let photoObj: PhotoComplete = populatePhoto(arrayDictionaryPhoto[photoIndex])
                let urlToCall: String = assembleUrlToLoadImageFromSearch(photoObj)
                
                let url: NSURL = NSURL(string: urlToCall)!
                if let imageData = NSData(contentsOfURL: url) {
                    dispatch_async(dispatch_get_main_queue(), {
                        let imageTemp: UIImage = UIImage(data: imageData)!
                        let titleLabel: UILabel = UILabel()
                        let photoDetailLabel: UILabel = UILabel()
                        titleLabel.text = photoObj.title
                        photoDetailLabel.text = self.EMPTY_STRING
                        self.photoResultReturn = PhotoResult(photoImage: imageTemp, photoTitle: titleLabel, photoDetail: photoDetailLabel)
                        handler(result: true)
                    })
                }
            } else {
                handler(result: false)
                print("No Result Found")
            }
        }
    }


    
//    // Make a POST request call from a url as string, this function is for the search by a text
//    func requestSearch(urlToCall: String, handler:(result: PhotoResult?)-> Void) {
//        let url: NSURL = NSURL(string: urlToCall)!
//        let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
//        request.HTTPMethod = POST_METHOD
//        
//        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ (response:NSURLResponse?, data: NSData?, error: NSError?) -> Void in
//            let error: AutoreleasingUnsafeMutablePointer<NSError?> = nil
//            let jsonResult: NSDictionary? = NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.MutableContainers) as? NSDictionary
//            
//            if (jsonResult != nil) {
//                self.requestPhoto(jsonResult!, itemsCount: jsonResult!.count, handler: { (result) -> Void in
//                    if let hasFinished = result {
//                        handler(result: self.photoResultReturn)
//                    } else {
//                        handler(result: nil)
//                    }
//                })
//            } else {
//                handler(result: nil)
//            }
//        })
//    }

}