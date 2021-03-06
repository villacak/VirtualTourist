//
//  UrlHelper.swift
//  Virtual Tourist
//
//  Created by Klaus Villaca on 12/29/15.
//  Copyright © 2015 Klaus Villaca. All rights reserved.
//

import Foundation
import UIKit
import CoreData


class UrlHelper: NSObject { //, NSURLConnectionDelegate {
    
    // Get Random
    var isRandom: Bool = false
    var photoResultReturn: Photo?
    
    //
    // Encode the Dictionary Strings
    //
    func encodeParameters(params: [String: String]) -> String {
        let queryItems = params.map { URLQueryItem(name:$0, value:$1)}
        var components = URLComponents()
        components.queryItems = queryItems
        return components.percentEncodedQuery ?? VTConstants.EMPTY_STRING
    }
    
    
    //
    // Assemble the Search with text url to perform a request for the search photo using a latitude and longitude
    //
    func createSearchByLatitudeLogitudeRequestURL(lat: String!, lon: String!) -> String {
        let urlParamsDictionary: Dictionary<String, String>  = [VTConstants.METHOD_DIC_KEY : VTConstants.URL_METHOD_SEARCH,
            VTConstants.API_DIC_KEY : VTConstants.URL_KEY_API,
            VTConstants.LATITUDE: lat!,
            VTConstants.LONGITUDE: lon!,
            VTConstants.FORMAT_DIC_KEY : VTConstants.URL_JSON_FORMAT,
            VTConstants.CALLBACK_DIC_KEY : VTConstants.URL_CALL_BACK]
        let encodedParamsString = encodeParameters(params: urlParamsDictionary)
        let urlToCall: String = VTConstants.URL_SEARCH_BASE + encodedParamsString
        return urlToCall
    }
    
    
    //
    // Parse NSDictionary to AnyObject - JSON
    //
    func parseNSDictionaryToJSON(_ nsDictionary: NSDictionary) -> AnyObject {
        let bytes: Data = try! JSONSerialization.data(withJSONObject: nsDictionary, options: JSONSerialization.WritingOptions())
        let jsonObj: AnyObject = (try! JSONSerialization.jsonObject(with: bytes, options: [])) as! NSDictionary
        return jsonObj
    }
    
    
    //
    // Populate Photo object
    //
    func populatePhoto(_ jsonObj: AnyObject) -> PhotoComplete {
        let photoObjectToReturn: PhotoComplete = PhotoComplete()
        photoObjectToReturn.farm = String((jsonObj["farm"] as? Int)!)
        photoObjectToReturn.id = jsonObj["id"]! as? String
        photoObjectToReturn.owner = jsonObj["owner"]! as? String
        photoObjectToReturn.secret = jsonObj["secret"]! as? String
        photoObjectToReturn.server = jsonObj["server"]! as? String
        photoObjectToReturn.title = jsonObj["title"]! as? String
        photoObjectToReturn.isPublic = String((jsonObj["ispublic"]! as? Int)!)
        photoObjectToReturn.isFriend = String((jsonObj["isfriend"]! as? Int)!)
        photoObjectToReturn.isFamily = String((jsonObj["isfamily"]! as? Int)!)
        return photoObjectToReturn
    }
    
    
    
    //
    // ASsemble the URL to load the images as per link: https://www.flickr.com/services/api/flickr.photos.search.html
    //
    func assembleUrlToLoadImageFromSearch(_ item: PhotoComplete) -> String {
        // URL to forms : https://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}.jpg
        let urlToReturn: String = "https://farm\(item.farm!).staticflickr.com/\(item.server!)/\(item.id!)_\(item.secret!).jpg"
        return urlToReturn
    }
 }
