//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Klaus Villaca on 12/7/15.
//  Copyright © 2015 Klaus Villaca. All rights reserved.
//

import UIKit
import MapKit

struct Pin {
    
    var id: NSNumber = 0
    var position: MKPointAnnotation = MKPointAnnotation()
    var photos: [Photo] = [Photo]()
    
    
    //
    // Empty initializer
    //
    init() {}
    
    
    init(id: NSNumber, position: MKPointAnnotation, photos: [Photo]) {
        self.id = id
        self.position = position
        self.photos = photos
    }
    
    init(photoDictionary: Dictionary<String, AnyObject>) {
        if let tempObjectId = photoDictionary[VTConstants.id] {
            id = tempObjectId as! NSNumber
        }
        if let tempObjectId = photoDictionary[VTConstants.position] {
            position = tempObjectId as! MKPointAnnotation
        }
        if let tempObjectId = photoDictionary[VTConstants.photos] {
            photos = tempObjectId as! [Photo]
        }
    }

}
