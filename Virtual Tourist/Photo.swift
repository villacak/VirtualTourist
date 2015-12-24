//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Klaus Villaca on 12/5/15.
//  Copyright © 2015 Klaus Villaca. All rights reserved.
//

import UIKit
import CoreData


class Photo: NSManagedObject {
    
    struct Keys {
        static let photo = "photo"
    }
    
    
    @NSManaged var id: NSNumber
    @NSManaged var photo: UIImage?
    @NSManaged var position: Pin?
    
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    
    init(photoDictionary: Dictionary<String, AnyObject>, context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        if let tempObjectId = photoDictionary[VTConstants.id] {
            id = tempObjectId as! NSNumber
        }
        if let tempObjectId = photoDictionary[VTConstants.photo] {
            photo = tempObjectId as? UIImage
        }
    }
}