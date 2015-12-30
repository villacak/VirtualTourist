//
//  PictureGridViewController.swift
//  Virtual Tourist
//
//  Created by Klaus Villaca on 12/19/15.
//  Copyright © 2015 Klaus Villaca. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PictureGridViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    
    
    @IBOutlet weak var picturesGridCol: UICollectionView!
    @IBOutlet weak var noImageLbl: UILabel!
    @IBOutlet weak var newCollectionBtn: UIButton!
    @IBOutlet weak var vtMapView: MKMapView!
    
    var appDelegate: AppDelegate!
    var photos: [Photo]?

    // Create the shared context
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        
        let backButton: UIBarButtonItem = UIBarButtonItem()
        backButton.title = "OK"
        navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        
        if let tempPhotos = appDelegate.pinSelected!.photos {
            photos = tempPhotos
            picturesGridCol.hidden = false
            noImageLbl.hidden = true
            newCollectionBtn.enabled = false
        } else {
            picturesGridCol.hidden = true
            noImageLbl.hidden = false
            newCollectionBtn.enabled = true
        }

        let latString: String = String((appDelegate.pinSelected?.latitude)!)
        let lonString: String = String((appDelegate.pinSelected?.longitude)!)
        let urlToCallTemp = UrlHelper().createSearchByLatitudeLogitudeRequestURL(lat: latString, lon: lonString)
        makeRESTCallAndGetResponse(urlToCallTemp, controller: self, contextManaged: sharedContext)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        let doubleLat: Double = Double((appDelegate.pinSelected?.latitude)!)
        let doubleLon: Double = Double((appDelegate.pinSelected?.longitude)!)
        
        let utils: Utils = Utils()
        let tempPointAnnotation: MKPointAnnotation = utils.retrieveAnnotation(latitude: doubleLat, longitude: doubleLon)
        vtMapView.addAnnotation(tempPointAnnotation)
        
        let userLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(tempPointAnnotation.coordinate.latitude, tempPointAnnotation.coordinate.longitude)
        vtMapView.setCenterCoordinate(userLocation, animated: true)
        
        let viewRegion = MKCoordinateRegionMakeWithDistance(userLocation, 500, 500)
        vtMapView.setRegion(viewRegion, animated: false)
    }
    
    


    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos!.count
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let photo: Photo = photos![indexPath.row]
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PictureSecondView", forIndexPath: indexPath) as! PinCollectionViewCell
        cell.imageViewTableCell?.image = photo.photo
        return cell
    }
    
    
    //
    // Function to call the service and populate data when response return
    //
    func makeRESTCallAndGetResponse(urlToCall: String, controller: UIViewController, contextManaged: NSManagedObjectContext) {
        let helperObject: Requests = Requests()
        // Change to false the line bellow and enable the second line to have option to select a picture
        // instead random
//        let isRandom: Bool = false
        helperObject.requestSearch(urlToCall: urlToCall, controller: controller, contextManaged: contextManaged, completionHandler: { (result, error) -> Void in
            if let photoResultTemp = result {
                self.photos = photoResultTemp as? [Photo]
//                if let _ = tempPhotoArray {
//                    for tempPhoto: Photo in tempPhotoArray! {
//                        tempPhotoArray?.append(tempPhoto)
//                    }
//                }
//                //                return tempPhotoArray!
            } else {
                Dialog().noResultsAlert(controller)
            }
        })
    }


}
