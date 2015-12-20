//
//  PictureGridViewController.swift
//  Virtual Tourist
//
//  Created by Klaus Villaca on 12/19/15.
//  Copyright © 2015 Klaus Villaca. All rights reserved.
//

import UIKit
import MapKit

class PictureGridViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    
    
    var appDelegate: AppDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let pin: Pin = appDelegate.pins[indexPath.row] as Pin!
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PictureSecondView", forIndexPath: indexPath) as! PinCollectionViewCell
        return cell
    }
    

}
