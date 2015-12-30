//
//  VirtualTouristDB.swift
//  Virtual Tourist
//
//  Created by Klaus Villaca on 12/30/15.
//  Copyright © 2015 Klaus Villaca. All rights reserved.
//

import Foundation


class VirtualTouristDB: NSObject {
    
    typealias CompletionHander = (result: AnyObject!, error: NSError?) -> Void
    
    var session: NSURLSession
    var config = Config.unarchivedInstance() ?? Config()
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    
    // MARK: - All purpose task method for data
    
    func taskForResource(resource: String, parameters: [String : AnyObject], completionHandler: CompletionHander) -> NSURLSessionDataTask {
        
        var mutableParameters = parameters
        var mutableResource = resource
        
        // Add in the API Key
        mutableParameters["api_key"] = VTConstants.URL_KEY_API
        
        // Substitute the id parameter into the resource
        if resource.rangeOfString(":id") != nil {
            assert(parameters[Keys.ID] != nil)
            
            mutableResource = mutableResource.stringByReplacingOccurrencesOfString(":id", withString: "\(parameters[Keys.ID]!)")
            mutableParameters.removeValueForKey(Keys.ID)
        }
        
        let urlString = VTConstants.URL_SEARCH_BASE + mutableResource + VirtualTouristDB.escapedParameters(mutableParameters)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        print(url)
        
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            if let error = downloadError {
                let newError = VirtualTouristDB.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: newError)
            } else {
                VirtualTouristDB.parseJSONWithCompletionHandler(data!, completionHandler: completionHandler)
            }
        }
        
        task.resume()
        
        return task
    }
    
    // MARK: - All purpose task method for images
    
    func taskForImageWithSize(size: String, filePath: String, completionHandler: (imageData: NSData?, error: NSError?) ->  Void) -> NSURLSessionTask {
        
//        let urlComponents = [size, filePath]
        let baseURL = NSURL(string: config.baseImageURLString)!
        let url = baseURL.URLByAppendingPathComponent(size).URLByAppendingPathComponent(filePath)
        
        print(url)
        
        let request = NSURLRequest(URL: url)
        
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            if let _ = downloadError {
                let newError = VirtualTouristDB.errorForData(data, response: response, error: downloadError!)
                completionHandler(imageData: nil, error: newError)
            } else {
                completionHandler(imageData: data, error: nil)
            }
        }
        
        task.resume()
        
        return task
    }
    
    // MARK: - Update Config
    
    func taskForUpdatingConfig(completionHandler: (didSucceed: Bool, error: NSError?) -> Void) -> NSURLSessionTask {
        
        var parameters = [String: AnyObject]()
        
        let task = taskForResource(Resources.Config, parameters: parameters) { JSONResult, error in
            
            if let error = error {
                completionHandler(didSucceed: false, error: error)
            } else if let newConfig = Config(dictionary: JSONResult as! [String : AnyObject]) {
                self.config = newConfig
                completionHandler(didSucceed: true, error: nil)
            } else {
                completionHandler(didSucceed: false, error: NSError(domain: "Config", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse config"]))
            }
        }
        
        task.resume()
        
        return task
    }
    
    
    // MARK: - Helpers
    
    
    // Try to make a better error, based on the status_message from TheMovieDB. If we cant then return the previous error
    
    class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {
        do {
            if let parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as? [String : AnyObject] {
                if let errorMessage = parsedResult[VirtualTouristDB.Keys.ErrorStatusMessage] as? String {
                    let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                    return NSError(domain: "VT Error", code: 1, userInfo: userInfo)
                }
            }
        } catch let error as NSError {
            return error
        }
    }
    
    // Parsing the JSON
    
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: CompletionHander) {
        do {
            let parsedResult: AnyObject? = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
            completionHandler(result: parsedResult, error: nil)
        } catch error as NsError {
            completionHandler(result: nil, error: error!)
        } catch {
            let error: NSError = NSError(domain: "<Your domain>", code: 1, userInfo: nil)
            completionHandler(result: nil, error: error)
        }
    }
    
    // URL Encoding a dictionary into a parameter string
    
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        var urlVars = [String]()
        
        for (key, value) in parameters {
            // Make sure that it is a string value
            let stringValue = "\(value)"
            // Escape it
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            // Append it
            urlVars += [key + "=" + "\(escapedValue!)"]
        }
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }
    
    
    // MARK: - Shared Instance
    class func sharedInstance() -> VirtualTouristDB {
        struct Singleton {
            static var sharedInstance = VirtualTouristDB()
        }
        return Singleton.sharedInstance
    }
    
    
    // MARK: - Shared Date Formatter
    class var sharedDateFormatter: NSDateFormatter  {
        struct Singleton {
            static let dateFormatter = Singleton.generateDateFormatter()
            static func generateDateFormatter() -> NSDateFormatter {
                let formatter = NSDateFormatter()
                formatter.dateFormat = "yyyy-mm-dd"
                return formatter
            }
        }
        return Singleton.dateFormatter
    }
    
    
    // MARK: - Shared Image Cache
    struct Caches {
        static let imageCache = ImageCache()
    }
    
}


