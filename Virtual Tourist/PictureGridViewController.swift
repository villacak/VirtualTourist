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

class PictureGridViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    @IBOutlet weak var picturesGridCol: UICollectionView!
    @IBOutlet weak var noImageLbl: UILabel!
    @IBOutlet weak var newCollectionBtn: UIButton!
    @IBOutlet weak var vtMapView: MKMapView!
    
    //    var noImageLbl: UILabel!
    var appDelegate: AppDelegate!
    var photos: [Photo]?
    
    var inMemoryCache = NSCache()
    var spinner: ActivityIndicatorView!
    
    // Create the shared context
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    
    //
    // Called when view will appear
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        
        picturesGridCol.delegate = self
        picturesGridCol.dataSource = self
        picturesGridCol.backgroundView = UIView()
        
        let backButton: UIBarButtonItem = UIBarButtonItem()
        backButton.title = "OK"
        navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        if let tempPhotos = appDelegate.pinSelected!.photos {
            photos = tempPhotos.allObjects as NSArray as? [Photo]
            if photos?.count > 0 {
                picturesGridCol.hidden = false
                noImageLbl.hidden = true
            } else {
                defaultSettingsForEmptyArray()
            }
        } else {
            photos = [Photo]()
            defaultSettingsForEmptyArray()
        }
        newCollectionBtn.enabled = true
    }
    
    
    //
    // Just a function to don't have neat and clean code
    //
    func defaultSettingsForEmptyArray() {
        picturesGridCol.hidden = true
        noImageLbl.hidden = false
        callNewCollection()
    }
    
    //
    // Called just after viewDidLoad and just before the view appear
    //
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
    
    
    //
    // Called just before the view disappear
    //
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        photos = nil
        appDelegate.pinSelected = nil
    }
    
    
    //
    // Return the count value that has the amount of items within the array
    //
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos!.count
    }
    
    
    //
    // Loop through each item to display it
    //
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let reusedIdentifier = "PictureSecondView"
        let photo: Photo = photos![indexPath.row]
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reusedIdentifier, forIndexPath: indexPath) as! PinCollectionViewCell
        cell.labelCell?.text = "\(photo.id)"
        cell.imageViewTableCell?.image = photo.posterImage
        cell.imageViewTableCell?.layer.borderWidth = 1.0
        cell.imageViewTableCell?.layer.borderColor = UIColor.blackColor().CGColor
        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        dialogWithOkAndCancel(indexPath.row)
    }
    
    
    //
    // Function to call the service and populate data when response return
    //
    func makeRESTCallAndGetResponse(urlToCall: String, pin: Pin!, controller: UIViewController, contextManaged: NSManagedObjectContext) {
        let helperObject: Requests = Requests()
        
        // As we are just replacing those images it's needed first remove them
        // Removing
        var greaterIDNumber: NSNumber = 0
        for tempPhoto: Photo in photos! {
            if (tempPhoto.id as Int) >= (greaterIDNumber as Int) {
                greaterIDNumber = tempPhoto.id
            }
            tempPhoto.posterImage = nil
            sharedContext.deleteObject(tempPhoto)
            do {
                try sharedContext.save()
            } catch let error as NSError {
                print("Error : \(error.localizedDescription)")
            }
        }
        CoreDataStackManager.sharedInstance().saveContext()
        
        
        // Change to false the line bellow and enable the second line to have option to select a picture
        // instead random
        helperObject.requestSearch(urlToCall: urlToCall, pin: pin, greaterID: greaterIDNumber as Int, controller: controller, contextManaged: contextManaged, completionHandler: { (result, error) -> Void in
            if let photoResultTemp = result {
                let tempPhotos: [Photo]? = photoResultTemp as? [Photo]
                if let _ = tempPhotos {
                    self.photos = tempPhotos
                }
                self.picturesGridCol.hidden = false
                self.noImageLbl.hidden = true
                dispatch_async(dispatch_get_main_queue()) {
                    self.newCollectionBtn.enabled = true
                    self.picturesGridCol.reloadData()
                    self.spinner.hide()
                }
                
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.newCollectionBtn.enabled = true
                    self.spinner.hide()
                    Dialog().okDismissAlert(titleStr: VTConstants.ERROR, messageStr: error!, controller: controller)
                }
            }
            
        })
    }
    
    
    
    //
    // New Collection Button
    //
    @IBAction func newCollectionBtn(sender: AnyObject) {
        callNewCollection()
    }
    
    
    //
    // Make the call for load a new collection
    //
    func callNewCollection() {
        newCollectionBtn.enabled = false
        spinner = ActivityIndicatorView(text: VTConstants.LOADING)
        view.addSubview(spinner)
        
        let latString: String = String((appDelegate.pinSelected?.latitude)!)
        let lonString: String = String((appDelegate.pinSelected?.longitude)!)
        let urlToCallTemp = UrlHelper().createSearchByLatitudeLogitudeRequestURL(lat: latString, lon: lonString)
        
        makeRESTCallAndGetResponse(urlToCallTemp, pin: appDelegate.pinSelected, controller: self, contextManaged: sharedContext)
    }
    
    
    //
    // Dialog for be used by the delete photo from collection view
    //
    func dialogWithOkAndCancel(photoIndexForDelete: Int!) {
        let alert: UIAlertController = UIAlertController(title: VTConstants.DELETE, message: VTConstants.DELETE_SINGLE_PIC, preferredStyle: UIAlertControllerStyle.Alert)
        let ok: UIAlertAction = UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
            self.deleteSinglePhoto(photoIndexForDelete)
        })
        
        let cancel: UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        
        alert.addAction(ok)
        alert.addAction(cancel)
        self.presentViewController(alert, animated: true, completion: {})
    }
    
    
    //
    // Delete a single picture from the collection
    //
    func deleteSinglePhoto(photoIndexForDelete: Int!) {
        if let tempPhoto = photos?[photoIndexForDelete] {
            do {
                sharedContext.deleteObject(tempPhoto)
                try sharedContext.save()
                Dialog().timedDismissAlert(titleStr: VTConstants.DELETE, messageStr: VTConstants.DELETED_SINGLE_PIC, secondsToDismmis: 2, controller: self)
                CoreDataStackManager.sharedInstance().saveContext()
                photos?.removeAtIndex(photoIndexForDelete)
                self.picturesGridCol.reloadData()
            } catch let error as NSError {
                Dialog().okDismissAlert(titleStr: VTConstants.ERROR, messageStr: error.localizedDescription, controller: self)
            }
        }
    }
    
}
