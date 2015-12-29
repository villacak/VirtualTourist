//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Klaus Villaca on 12/5/15.
//  Copyright © 2015 Klaus Villaca. All rights reserved.
//

import Foundation
import UIKit
import CoreData

@objc(Photo)
class Photo: NSManagedObject {
    
    struct Keys {
        static let Photo: String = "Photo"
        static let photo: String = "photo"
        static let ID: String = "id"
    }
    
    
    @NSManaged var id: NSNumber
    @NSManaged var photo: UIImage?
    @NSManaged var position: Pin?
    
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    
    init(photoDictionary: Dictionary<String, AnyObject>, context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName(Photo.Keys.Photo, inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        if let tempObjectId = photoDictionary[Keys.ID] {
            id = tempObjectId as! Int
        }
        if let tempObjectId = photoDictionary[Keys.photo] {
            photo = tempObjectId as? UIImage
        }
    }
}