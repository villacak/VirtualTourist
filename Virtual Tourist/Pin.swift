//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Klaus Villaca on 12/7/15.
//  Copyright © 2015 Klaus Villaca. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class Pin: NSManagedObject {
    
    struct Keys {
        static let ID = "id"
        static let position = "position"
        static let photos = "photos"
    }
    
    @NSManaged var id: NSNumber
    @NSManaged var position: MKPointAnnotation?
    @NSManaged var photos: [Photo]?
    
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    
    init(photoDictionary: Dictionary<String, AnyObject>, context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        if let tempObjectId = photoDictionary[VTConstants.id] {
            id = tempObjectId as! NSNumber
        }
        if let tempObjectId = photoDictionary[VTConstants.position] {
            position = tempObjectId as? MKPointAnnotation
        }
        if let tempObjectId = photoDictionary[VTConstants.photos] {
            photos = tempObjectId as? [Photo]
        }
    }

}
