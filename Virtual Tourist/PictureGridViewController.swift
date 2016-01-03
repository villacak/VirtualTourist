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
    var photosNumberBelongingToThePin: Int = 0
    
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
                photosNumberBelongingToThePin = photos!.count
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
    
    
    //
    // Function to call the service and populate data when response return
    //
    func makeRESTCallAndGetResponse(urlToCall: String, numberOfPics: Int!, pin: Pin!, controller: UIViewController, contextManaged: NSManagedObjectContext) {
        let helperObject: Requests = Requests()
        // Change to false the line bellow and enable the second line to have option to select a picture
        // instead random
        helperObject.requestSearch(urlToCall: urlToCall, numberOfPics: numberOfPics, pin: pin, controller: controller, contextManaged: contextManaged, completionHandler: { (result, error) -> Void in
            if let photoResultTemp = result {
                let tempPhotos: [Photo]? = photoResultTemp as? [Photo]
                if let _ = tempPhotos {
                    self.prepateItemToPersistAndUpdateIt(tempPhotos!)
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
                    Dialog().noResultsAlert(controller)
                }
            }
            
        })
    }
    
    
    //
    // Update the Pin record and pin selected
    //
    func prepateItemToPersistAndUpdateIt(tempPhotos: [Photo]!) {
        for tempPhoto: Photo in tempPhotos! {
            self.photos?.append(tempPhoto)
        }
    }
        
    
    //
    // New Collection Button
    //
    @IBAction func newCollectionBtn(sender: AnyObject) {
        newCollectionBtn.enabled = false
        spinner = ActivityIndicatorView(text: VTConstants.LOADING)
        view.addSubview(spinner)
        
        let latString: String = String((appDelegate.pinSelected?.latitude)!)
        let lonString: String = String((appDelegate.pinSelected?.longitude)!)
        let urlToCallTemp = UrlHelper().createSearchByLatitudeLogitudeRequestURL(lat: latString, lon: lonString)
        photosNumberBelongingToThePin = photos!.count
        
        makeRESTCallAndGetResponse(urlToCallTemp, numberOfPics: photosNumberBelongingToThePin, pin: appDelegate.pinSelected, controller: self, contextManaged: sharedContext)
    }
    
}
