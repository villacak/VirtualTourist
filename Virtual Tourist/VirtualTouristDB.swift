//
//  VirtualTouristDB.swift
//  Virtual Tourist
//
//  Created by Klaus Villaca on 12/30/15.
//  Copyright © 2015 Klaus Villaca. All rights reserved.
//

import Foundation


class VirtualTouristDB: NSObject {
    
    typealias CompletionHander = (_ result: AnyObject?, _ error: NSError?) -> Void
    
    var session: URLSession
    var config = Config.unarchivedInstance() ?? Config()
    
    override init() {
        session = URLSession.shared
        super.init()
    }
    
    //
    // MARK: - All purpose task method for data
    //
    func taskForResource(_ resource: String, parameters: [String : AnyObject], completionHandler: CompletionHander) -> URLSessionDataTask {
        var mutableParameters = parameters
        var mutableResource = resource
        

        mutableParameters["api_key"] = VTConstants.URL_KEY_API
        if resource.range(of: ":id") != nil {
            assert(parameters[Keys.ID] != nil)
            mutableResource = mutableResource.replacingOccurrences(of: ":id", with: "\(parameters[Keys.ID]!)")
            mutableParameters.removeValue(forKey: Keys.ID)
        }
        
        let urlString = VTConstants.URL_SEARCH_BASE + mutableResource + VirtualTouristDB.escapedParameters(mutableParameters)
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        
        print(url)
        
        let task = session.dataTask(with: request) {data, response, downloadError in
            if let error = downloadError {
                let newError = VirtualTouristDB.errorForData(data, response: response, error: error as NSError)
                completionHandler(nil, newError)
            } else {
                VirtualTouristDB.parseJSONWithCompletionHandler(data!, completionHandler: completionHandler)
            }
        }
        task.resume()
        return task
    }
    
    
    //
    // MARK: - All purpose task method for images
    //
    func taskForImageWithSize(_ size: String, filePath: String, completionHandler: @escaping (_ imageData: Data?, _ error: NSError?) ->  Void) -> URLSessionTask {
        let baseURL = URL(string: config.baseImageURLString)!
        let url = baseURL.appendingPathComponent(size).appendingPathComponent(filePath)
        print(url)
        
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) {data, response, downloadError in
            if let _ = downloadError {
                let newError = VirtualTouristDB.errorForData(data, response: response, error: downloadError! as NSError)
                completionHandler(nil, newError)
            } else {
                completionHandler(data, nil)
            }
        }
        task.resume()
        return task
    }
    
    
    //
    // MARK: - Update Config
    //
    func taskForUpdatingConfig(_ completionHandler: @escaping (_ didSucceed: Bool, _ error: NSError?) -> Void) -> URLSessionTask {
        let parameters = [String: AnyObject]()
        let task = taskForResource(Resources.Config, parameters: parameters) { JSONResult, error in
            if let error = error {
                completionHandler(false, error)
            } else if let newConfig = Config(dictionary: JSONResult as! [String : AnyObject]) {
                self.config = newConfig
                completionHandler(true, nil)
            } else {
                completionHandler(false, NSError(domain: "Config", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse config"]))
            }
        }
        task.resume()
        return task
    }
    
    
    
    // MARK: - Helpers
    
    //
    // Try to make a better error, based on the status_message. If we cant then return the previous error
    //
    class func errorForData(_ data: Data?, response: URLResponse?, error: NSError) -> NSError {
        var errorToReturn: NSError?
        do {
            if let parsedResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? [String : AnyObject] {
                if let errorMessage = parsedResult[VirtualTouristDB.Keys.ErrorStatusMessage] as? String {
                    let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                    errorToReturn = NSError(domain: "VT Error", code: 1, userInfo: userInfo)
                }
            }
        } catch let error as NSError {
            errorToReturn = error
        }
        return errorToReturn!
    }
    
    
    //
    // Parsing the JSON
    //
    class func parseJSONWithCompletionHandler(_ data: Data, completionHandler: CompletionHander) {
        do {
            let parsedResult: AnyObject? = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
            completionHandler(parsedResult, nil)
        } catch  {
            let tempError: NSError = NSError(domain: "Fail parsing JSON", code: 1, userInfo: nil)
            completionHandler(nil, tempError)
        }
    }
    
    
    //
    // URL Encoding a dictionary into a parameter string
    //
    class func escapedParameters(_ parameters: [String : AnyObject]) -> String {
        var urlVars = [String]()
        for (key, value) in parameters {
            let stringValue = "\(value)"
            let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            urlVars += [key + "=" + "\(escapedValue!)"]
        }
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joined(separator: "&")
    }
    
    
    //
    // MARK: - Shared Instance
    //
    class func sharedInstance() -> VirtualTouristDB {
        struct Singleton {
            static var sharedInstance = VirtualTouristDB()
        }
        return Singleton.sharedInstance
    }
    
    //
    // MARK: - Shared Date Formatter
    //
    class var sharedDateFormatter: DateFormatter  {
        struct Singleton {
            static let dateFormatter = Singleton.generateDateFormatter()
            static func generateDateFormatter() -> DateFormatter {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-mm-dd"
                return formatter
            }
        }
        return Singleton.dateFormatter
    }
    
    
    //
    // MARK: - Shared Image Cache
    //
    struct Caches {
        static let imageCache = ImageCache()
    }
    
}


