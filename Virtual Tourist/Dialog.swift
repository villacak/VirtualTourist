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
    func okDismissAlert(titleStr titleStr: String!, messageStr: String!, controller: UIViewController) {
        let alert: UIAlertController = UIAlertController(title: titleStr, message: messageStr, preferredStyle: UIAlertControllerStyle.Alert)
        let okDismiss: UIAlertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(okDismiss)
        controller.presentViewController(alert, animated: true, completion: {})
    }
    
    
    //
    // UIAlertDisplay dismiss by time
    //
    func timedDismissAlert(titleStr titleStr: String!, messageStr: String!, secondsToDismmis: Double!, controller: UIViewController) {
        let alert: UIAlertController = UIAlertController(title: titleStr, message: messageStr, preferredStyle: UIAlertControllerStyle.Alert)
        controller.presentViewController(alert, animated: true, completion: {})
        
        let delay = secondsToDismmis * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(), {
            alert.dismissViewControllerAnimated(true, completion: nil)
        })
        
    }
    
    
    //
    // Just display an alert, telling the search was empty
    //
    func noResultsAlert(controller: UIViewController) {
        okDismissAlert(titleStr: "Empty Result", messageStr: "The search didn't return any results", controller: controller)
    }
    
}
