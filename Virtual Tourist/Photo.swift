//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Klaus Villaca on 12/5/15.
//  Copyright © 2015 Klaus Villaca. All rights reserved.
//

import UIKit
import CoreData


struct Photo {
    
//    struct Keys {
//        static let photo = "photo"
//    }
    
    var id: NSNumber = 0
    var photo: UIImage = UIImage()
    
    init(){}
    
    init(id: NSNumber, photo: UIImage) {
        self.id = id
        self.photo = photo
    }
    
    init(photoDictionary: Dictionary<String, AnyObject>) {
        if let tempObjectId = photoDictionary[VTConstants.id] {
            id = tempObjectId as! NSNumber
        }
        if let tempObjectId = photoDictionary[VTConstants.photo] {
            photo = tempObjectId as! UIImage
        }
    }
}