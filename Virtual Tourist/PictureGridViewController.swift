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
    
    
    @IBOutlet weak var picturesGridCol: UICollectionView!
    @IBOutlet weak var noImageLbl: UICollectionView!
    @IBOutlet weak var newCollectionBtn: UIButton!
    @IBOutlet weak var vtMapView: MKMapView!
    
    var appDelegate: AppDelegate!
    var photos: [Photo]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        
        if appDelegate.pinSelected.photos.count > 0 {
            photos = appDelegate.pinSelected.photos
            picturesGridCol.hidden = false
            noImageLbl.hidden = true
            newCollectionBtn.enabled = false
        } else {
            picturesGridCol.hidden = true
            noImageLbl.hidden = false
            newCollectionBtn.enabled = true
            
        }
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        let tempPointAnnotation: MKPointAnnotation = appDelegate.pinSelected.position
        vtMapView.addAnnotation(tempPointAnnotation)
        
        let userLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(tempPointAnnotation.coordinate.latitude, tempPointAnnotation.coordinate.longitude)
        vtMapView.setCenterCoordinate(userLocation, animated: true)
        
        let viewRegion = MKCoordinateRegionMakeWithDistance(userLocation, 500, 500)
        vtMapView.setRegion(viewRegion, animated: false)
    }


    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let photo: Photo = photos[indexPath.row]
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PictureSecondView", forIndexPath: indexPath) as! PinCollectionViewCell
        cell.imageViewTableCell?.image = photo.photo
        return cell
    }
    

}
