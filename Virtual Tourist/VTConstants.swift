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
    
    // Messages strings
    static let LOADING: String = "Loading..."
    static let NO_IMAGE: String = "No Image(s)"
    
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