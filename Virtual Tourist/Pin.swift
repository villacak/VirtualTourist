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
        static let Pin = "Pin"
        static let ID = "id"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let photos = "photos"
    }
    
    @NSManaged var id: NSNumber
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var photos: [Photo]?
    
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    
    init(photoDictionary: [String: AnyObject], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        id = photoDictionary[Keys.ID] as! NSNumber
        latitude = photoDictionary[Keys.latitude] as! Double
        longitude = photoDictionary[Keys.longitude] as! Double
    }

}
