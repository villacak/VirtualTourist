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
    
    //
    // Remove the Pin object from the Array, from the MKPointAnnotation
    //
    func removePinFromArray(var pinArray pinArray: [Pin], pinToRemove: MKAnnotation) -> [Pin]{
        var idToRemove: Int!
        for tempPin: Pin in pinArray {
            if tempPin.latitude == pinToRemove.coordinate.latitude &&
                tempPin.longitude == pinToRemove.coordinate.longitude {
                    idToRemove = tempPin.id as Int
                    break
            }
        }
        
        if let _ = idToRemove {
            pinArray.removeAtIndex(idToRemove)
        }
        return pinArray
    }
    
    
    //
    // Retrieve the Pin object from MKPointAnnotation
    //
    func retrievePinFromArray(pinArray pinArray: [Pin], pinToRemove: MKAnnotation) -> Pin? {
        var pinToReturn: Pin!
        for tempPin: Pin in pinArray {
            if tempPin.latitude == pinToRemove.coordinate.latitude &&
                tempPin.longitude == pinToRemove.coordinate.longitude {
                    pinToReturn = tempPin
                    break
            }
        }
        return pinToReturn
    }
    
    
    //
    // From latitude and longitude return MKPointAnnotation
    //
    func retrieveAnnotation(latitude latitude: Double, longitude: Double) -> MKPointAnnotation {
        let annotationToReturn: MKPointAnnotation = MKPointAnnotation()
        annotationToReturn.coordinate.latitude = latitude
        annotationToReturn.coordinate.longitude = longitude
        return annotationToReturn
    }
}
