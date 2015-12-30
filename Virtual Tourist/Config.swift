//
//  Config.swift
//  Virtual Tourist
//
//  Created by Klaus Villaca on 12/30/15.
//  Copyright © 2015 Klaus Villaca. All rights reserved.
//

import Foundation
import UIKit


private let _documentsDirectoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
private let _fileURL: NSURL = _documentsDirectoryURL.URLByAppendingPathComponent("VirtualTouristDB-Context")

class Config: NSObject, NSCoding {
    var baseImageURLString = "http://image.tmdb.org/t/p/"
    var secureBaseImageURLString =  "https://image.tmdb.org/t/p/"
    var posterSizes = ["w92", "w154", "w185", "w342", "w500", "w780", "original"]
    var profileSizes = ["w45", "w185", "h632", "original"]
    var dateUpdated: NSDate? = nil
    
    override init() {
        
    }
    
    convenience init?(dictionary: [String : AnyObject]) {
        
        self.init()
        
        if let imageDictionary = dictionary[VirtualTouristDB.Keys.ConfigImages] as? [String : AnyObject] {
            
            if let urlString = imageDictionary[VirtualTouristDB.Keys.ConfigBaseImageURL] as? String {
                baseImageURLString = urlString
            } else {return nil}
            
            if let urlString = imageDictionary[VirtualTouristDB.Keys.ConfigBaseImageURL] as? String {
                secureBaseImageURLString = urlString
            } else {return nil}
            
            if let posterSizesArray = imageDictionary[VirtualTouristDB.Keys.ConfigPosterSizes] as? [String] {
                posterSizes = posterSizesArray
            } else {return nil}
            
            if let profileSizesArray = imageDictionary[VirtualTouristDB.Keys.ConfigProfileSizes] as? [String] {
                profileSizes = profileSizesArray
            } else {return nil}
            
            dateUpdated = NSDate()
            
        } else {
            return nil
        }
    }
    
    
    // Returns the number days since the config was last updated.
    
    var daysSinceLastUpdate: Int? {
        
        if let lastUpdate = dateUpdated {
            return Int(NSDate().timeIntervalSinceDate(lastUpdate)) / 60*60*24
        } else {
            return nil
        }
    }
    
    func updateIfDaysSinceUpdateExceeds(days: Int) {
        
        // If the config is up to date then return
        if let daysSinceLastUpdate = daysSinceLastUpdate {
            if (daysSinceLastUpdate <= days) {
                return
            }
        }
        
        // Otherwise, update
        VirtualTouristDB.sharedInstance().taskForUpdatingConfig() { didSucceed, error in
            
            if let error = error {
                print("Error updating config: \(error.localizedDescription)")
            } else {
                print("Updated Config: \(didSucceed)")
                VirtualTouristDB.sharedInstance().config.save()
            }
        }
    }
    
    // MARK: - NSCoding
    
    let BaseImageURLStringKey = "config.base_image_url_string_key"
    let SecureBaseImageURLStringKey =  "config.secure_base_image_url_key"
    let PosterSizesKey = "config.poster_size_key"
    let ProfileSizesKey = "config.profile_size_key"
    let DateUpdatedKey = "config.date_update_key"
    
    required init(coder aDecoder: NSCoder) {
        baseImageURLString = aDecoder.decodeObjectForKey(BaseImageURLStringKey) as! String
        secureBaseImageURLString = aDecoder.decodeObjectForKey(SecureBaseImageURLStringKey) as! String
        posterSizes = aDecoder.decodeObjectForKey(PosterSizesKey) as! [String]
        profileSizes = aDecoder.decodeObjectForKey(ProfileSizesKey) as! [String]
        dateUpdated = aDecoder.decodeObjectForKey(DateUpdatedKey) as? NSDate
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(baseImageURLString, forKey: BaseImageURLStringKey)
        aCoder.encodeObject(secureBaseImageURLString, forKey: SecureBaseImageURLStringKey)
        aCoder.encodeObject(posterSizes, forKey: PosterSizesKey)
        aCoder.encodeObject(profileSizes, forKey: ProfileSizesKey)
        aCoder.encodeObject(dateUpdated, forKey: DateUpdatedKey)
    }
    
    func save() {
        NSKeyedArchiver.archiveRootObject(self, toFile: _fileURL.path!)
    }
    
    class func unarchivedInstance() -> Config? {
        
        if NSFileManager.defaultManager().fileExistsAtPath(_fileURL.path!) {
            return NSKeyedUnarchiver.unarchiveObjectWithFile(_fileURL.path!) as? Config
        } else {
            return nil
        }
    }
}
