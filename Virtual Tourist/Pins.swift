//
//  Pins.swift
//  Virtual Tourist
//
//  Created by Klaus Villaca on 12/20/15.
//  Copyright © 2015 Klaus Villaca. All rights reserved.
//

//import Foundation
//
//struct Pins {
//    
//    var id: NSNumber = 0
//    var pins: [Pin] = [Pin]()
//    
//    //
//    // Empty initializer
//    //
//    init() {}
//    
//    
//    init(id: NSNumber, pins: [Pin]) {
//        self.id = id
//        self.pins = pins
//    }
//    
//    init(photoDictionary: Dictionary<String, AnyObject>) {
//        if let tempObjectId = photoDictionary[VTConstants.id] {
//            id = tempObjectId as! NSNumber
//        }
//        if let tempObjectId = photoDictionary[VTConstants.pins] {
//            pins = tempObjectId as! [Pin]
//        }
//    }
//
//}
