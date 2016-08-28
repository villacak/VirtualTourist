//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Klaus Villaca on 12/7/15.
//  Copyright © 2015 Klaus Villaca. All rights reserved.
//

import Foundation
import CoreData

@objc(Pin)
class Pin: NSManagedObject {
    
    struct Keys {
        static let PinClass: String = "Pin"
        static let ID: String = "id"
        static let latitude: String = "latitude"
        static let longitude: String = "longitude"
        static let photos: String = "photos"
    }
    
    @NSManaged var id: NSNumber
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var photos: NSSet?
    
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    
    init(photoDictionary: [String: AnyObject], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entity(forEntityName: Keys.PinClass, in: context)!
        super.init(entity: entity,insertInto: context)
        
        id = photoDictionary[Keys.ID] as! Int
        latitude = photoDictionary[Keys.latitude] as! Double
        longitude = photoDictionary[Keys.longitude] as! Double
    }
    
}
