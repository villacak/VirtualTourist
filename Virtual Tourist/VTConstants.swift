//
//  VTConstants.swift
//  Virtual Tourist
//
//  Created by Klaus Villaca on 12/6/15.
//  Copyright © 2015 Klaus Villaca. All rights reserved.
//

import Foundation

//
// Constants class
//
class VTConstants: NSObject {
    
    // Application Name
    static let appTitle: String = "Virtual Tourist"
    
    
    // Standard parts for URL formation
    static let URL_SEARCH_BASE: String = "https://api.flickr.com/services/rest/?"
    static let URL_METHOD_SEARCH: String = "flickr.photos.search"
    static let URL_KEY_API: String = "c2589f04f4ec12443e4a919390aa4e1c"
    static let URL_JSON_FORMAT: String = "json"
    static let URL_CALL_BACK: String = "1"
    static let URL_EXTRAS: String = "url_m"
    
    // Empty String
    static let EMPTY_STRING: String = ""
    
    static let BATCH_SIZE: Int = 10
    static let DEFAULT_KEY: String = "updatePins"
    
    // Messages strings
    static let DELETE:String = "Delete"
    static let LOADING: String = "Loading..."
    static let PREPARING: String = "Preparing..."
    static let NO_IMAGE: String = "No Image(s)"
    static let ERROR: String = "Error"
    static let ADD_PIN: String = "Adding Pin"
    static let ADD_PIN_MESSAGE: String = "Press and hold on the desired location for 0.8 seconds to add the pin."
    static let DELETE_MESSAGE: String = "To delete, just tap on top of the pin that you want to delete"
    static let DELETED_MESSAGE: String = "Pin and pictures removed"
    static let DELETE_SINGLE_PIC: String = "Do you want delete this photo?"
    static let DELETED_SINGLE_PIC: String = "Photo has been deleted."
    
    // Keys used in the URL params
    static let METHOD_DIC_KEY: String = "method"
    static let API_DIC_KEY: String = "api_key"
    static let TEXT_DIC_LEY: String = "text"
    static let FORMAT_DIC_KEY: String = "format"
    static let CALLBACK_DIC_KEY: String = "nojsoncallback"
    static let EXTRAS: String = "extras"
    static let LATITUDE: String = "lat"
    static let LONGITUDE: String = "lon"
    
    
    // REST Call Methods
    static let GET_METHOD = "GET"
    static let POST_METHOD = "POST"
    static let PUT_METHOD = "PUT"
    static let DELETE_METHOD = "DELETE"
}