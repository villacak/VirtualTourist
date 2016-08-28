//
//  Dialog.swift
//  Virtual Tourist
//
//  Created by Klaus Villaca on 12/6/15.
//  Copyright © 2015 Klaus Villaca. All rights reserved.
//

import UIKit


class Dialog: NSObject {
    
    //
    // UIAlertDisplay with one ok buttom to dismiss
    //
    func okDismissAlert(titleStr: String!, messageStr: String!, controller: UIViewController) {
        let alert: UIAlertController = UIAlertController(title: titleStr, message: messageStr, preferredStyle: UIAlertControllerStyle.alert)
        let okDismiss: UIAlertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(okDismiss)
        controller.present(alert, animated: true, completion: {})
    }
    
    
    //
    // UIAlertDisplay dismiss by time
    //
    func timedDismissAlert(titleStr: String!, messageStr: String!, secondsToDismmis: Double!, controller: UIViewController) {
        let alert: UIAlertController = UIAlertController(title: titleStr, message: messageStr, preferredStyle: UIAlertControllerStyle.alert)
        controller.present(alert, animated: true, completion: {})
        
        let delay = secondsToDismmis * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time, execute: {
            alert.dismiss(animated: true, completion: nil)
        })
        
    }
    
    
    //
    // Just display an alert, telling the search was empty
    //
    func noResultsAlert(_ controller: UIViewController) {
        okDismissAlert(titleStr: "Empty Result", messageStr: "The search didn't return any results", controller: controller)
    }
    
}
