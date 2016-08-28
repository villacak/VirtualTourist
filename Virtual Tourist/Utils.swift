//
//  Utils.swift
//  Virtual Tourist
//
//  Created by Klaus Villaca on 12/21/15.
//  Copyright © 2015 Klaus Villaca. All rights reserved.
//


import UIKit
import MapKit
import CoreData


class Utils: NSObject {
    
    //
    // Remove the Pin object from the Array, from the MKPointAnnotation
    //
    func removePinFromArray(pinArray: [Pin], pinToRemove: MKAnnotation) -> [Pin]{
        var tempPinArray: [Pin] = pinArray
        var idToRemove: Int!
        for tempPin: Pin in tempPinArray {
            if tempPin.latitude == pinToRemove.coordinate.latitude &&
                tempPin.longitude == pinToRemove.coordinate.longitude {
                    idToRemove = tempPin.id as Int
                    break
            }
        }
        
        if let _ = idToRemove {
            if idToRemove > 0 {
                tempPinArray.remove(at: idToRemove - 1)
            } else if idToRemove == 0 {
                tempPinArray.remove(at: idToRemove)
            }
        }
        return tempPinArray
    }
    
    
    //
    // Retrieve the Pin object from MKPointAnnotation
    //
    func retrievePinFromArray(pinArray: [Pin], pinToRemove: MKAnnotation) -> Pin? {
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
    func retrieveAnnotation(latitude: Double, longitude: Double) -> MKPointAnnotation {
        let annotationToReturn: MKPointAnnotation = MKPointAnnotation()
        annotationToReturn.coordinate.latitude = latitude
        annotationToReturn.coordinate.longitude = longitude
        return annotationToReturn
    }
    
    
    //
    // Remove pin, removes the pin from the DB
    //
    func removePin(pinArray: [Pin]!, pinAnnotation: MKAnnotation!, sharedContext: NSManagedObjectContext, controller: UIViewController ) -> Bool {
        var isDeleted: Bool = false
        let util: Utils = Utils()
        let pinToRemove: Pin? = util.retrievePinFromArray(pinArray: pinArray, pinToRemove: pinAnnotation!)!
        
        // Should have a easier way to retreive one record from DB than doing this, or retrieve from the fetchedResultsController var
        let fetchRequest = NSFetchRequest(entityName: Pin.Keys.PinClass)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = NSPredicate(format: "id == %@", (pinToRemove?.id)!)
        let sorter: NSSortDescriptor = NSSortDescriptor(key: "id" , ascending: true)
        fetchRequest.sortDescriptors = [sorter]
        
        var result: [Pin]?
        do {
            result = try sharedContext.fetch(fetchRequest) as? [Pin]
        } catch let error as NSError{
            Dialog().okDismissAlert(titleStr: VTConstants.ERROR, messageStr: error.localizedDescription, controller: controller)
            print("Error: \(error.localizedDescription)")
            result = nil
        }
        
        if let _ = pinToRemove {
            for resultItem: Pin in result! {
                if (resultItem.latitude == pinToRemove?.latitude && resultItem.longitude == pinToRemove?.longitude) {
                    // Using delete rules for Pin as cascade I can delete all childs records wihtout need to loop through it
                    // removeCachedImages(resultItem.photos!)
                    sharedContext.delete(resultItem)
                    do {
                        try sharedContext.save()
                        isDeleted = true
                    } catch let error as NSError {
                        // I rollback if something went wrong.
                        sharedContext.rollback()
                        Dialog().okDismissAlert(titleStr: VTConstants.ERROR, messageStr: error.localizedDescription, controller: controller)
                        print("Error : \(error.localizedDescription)")
                    }
                    break
                }
            }
        }
        return isDeleted
    }
    
}
