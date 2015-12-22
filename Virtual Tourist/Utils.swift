//
//  Utils.swift
//  Virtual Tourist
//
//  Created by Klaus Villaca on 12/21/15.
//  Copyright © 2015 Klaus Villaca. All rights reserved.
//


import UIKit
import MapKit


class Utils: NSObject {
    
    func removePinFromArray(var pinArray pinArray: [Pin], pinToRemove: MKAnnotation) -> [Pin]{
        var idToRemove: Int!
        for tempPin: Pin in pinArray {
            if tempPin.position!.coordinate.latitude == pinToRemove.coordinate.latitude &&
                tempPin.position!.coordinate.longitude == pinToRemove.coordinate.longitude {
                    idToRemove = tempPin.id as Int
                    break
            }
        }
        
        if let _ = idToRemove {
            pinArray.removeAtIndex(idToRemove)
        }
        return pinArray
    }
}
