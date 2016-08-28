//
//  Config.swift
//  Virtual Tourist
//
//  Copied and adapted from other Udacity project
//  2015 Klaus Villaca. All rights reserved.
//

import Foundation
import UIKit


private let _documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as URL
private let _fileURL: URL = _documentsDirectoryURL.appendingPathComponent("VirtualTouristDB-Context")

class Config: NSObject, NSCoding {
    var baseImageURLString = "http://image.tmdb.org/t/p/"
    var secureBaseImageURLString =  "https://image.tmdb.org/t/p/"
    var posterSizes = ["w92", "w154", "w185", "w342", "w500", "w780", "original"]
    var profileSizes = ["w45", "w185", "h632", "original"]
    var dateUpdated: Date? = nil
    
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
            
            dateUpdated = Date()
            
        } else {
            return nil
        }
    }
    
    
    // Returns the number days since the config was last updated.
    
    var daysSinceLastUpdate: Int? {
        
        if let lastUpdate = dateUpdated {
            return Int(Date().timeIntervalSince(lastUpdate)) / 60*60*24
        } else {
            return nil
        }
    }
    
    func updateIfDaysSinceUpdateExceeds(_ days: Int) {
        
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
    
    //
    // MARK: - NSCoding
    //
    let BaseImageURLStringKey = "config.base_image_url_string_key"
    let SecureBaseImageURLStringKey =  "config.secure_base_image_url_key"
    let PosterSizesKey = "config.poster_size_key"
    let ProfileSizesKey = "config.profile_size_key"
    let DateUpdatedKey = "config.date_update_key"
    
    required init(coder aDecoder: NSCoder) {
        baseImageURLString = aDecoder.decodeObject(forKey: BaseImageURLStringKey) as! String
        secureBaseImageURLString = aDecoder.decodeObject(forKey: SecureBaseImageURLStringKey) as! String
        posterSizes = aDecoder.decodeObject(forKey: PosterSizesKey) as! [String]
        profileSizes = aDecoder.decodeObject(forKey: ProfileSizesKey) as! [String]
        dateUpdated = aDecoder.decodeObject(forKey: DateUpdatedKey) as? Date
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(baseImageURLString, forKey: BaseImageURLStringKey)
        aCoder.encode(secureBaseImageURLString, forKey: SecureBaseImageURLStringKey)
        aCoder.encode(posterSizes, forKey: PosterSizesKey)
        aCoder.encode(profileSizes, forKey: ProfileSizesKey)
        aCoder.encode(dateUpdated, forKey: DateUpdatedKey)
    }
    
    func save() {
        NSKeyedArchiver.archiveRootObject(self, toFile: _fileURL.path)
    }
    
    class func unarchivedInstance() -> Config? {
        
        if FileManager.default.fileExists(atPath: _fileURL.path) {
            return NSKeyedUnarchiver.unarchiveObject(withFile: _fileURL.path) as? Config
        } else {
            return nil
        }
    }
}
