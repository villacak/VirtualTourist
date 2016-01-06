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
    
    var dataDictionary: NSDictionary?!
    var appDelegate: AppDelegate!
    var photos: [Photo]?
    var batchSize: Int = 0
    var photoIndex: Int = 250
    var jsonPhotos: [String : AnyObject]?
    var arrayDictionaryPhoto: [[String : AnyObject]]?
    var isCallNewCollection: Bool = false
    
    var inMemoryCache = NSCache()
    var spinner: ActivityIndicatorViewExt!
    
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
                batchSize = VTConstants.BATCH_SIZE
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
        return batchSize //photos!.count
    }
    
    
    //
    // Loop through each item to display it
    //
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let reusedIdentifier = "PictureSecondView"
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reusedIdentifier, forIndexPath: indexPath) as! PinCollectionViewCell
        cell.imageViewTableCell?.layer.borderWidth = 1.0
        cell.imageViewTableCell?.layer.borderColor = UIColor.blackColor().CGColor
        cell.cellSpinner.startAnimating()
        
        if (isCallNewCollection) {
            checkCounters()
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
                if (self.photoIndex < self.arrayDictionaryPhoto?.count) {
                    let photoResultTuple = self.requestPhoto(self.cellUrlHelper(self.photoIndex))
                    if let photoResultTemp = photoResultTuple.photoObject {
                        let tempPhoto: Photo! = photoResultTemp
                        self.photos?.append(tempPhoto!)
                        dispatch_barrier_async(dispatch_get_main_queue(), {() -> Void in
                            self.picturesGridCol.reloadData()
                            cell.cellSpinner.stopAnimating()
                            cell.cellSpinner.hidden = true
//                            cell.labelCell?.text = "\(tempPhoto!.id)"
//                            cell.imageViewTableCell?.image = tempPhoto!.posterImage
                        })
                    }
                }
            })
        } else {
            let photoTemp: Photo = photos![indexPath.row]
            cell.cellSpinner.stopAnimating()
            cell.labelCell?.text = "\(photoTemp.id)"
            cell.imageViewTableCell?.image = photoTemp.posterImage
        }
        return cell
    }
    
    
    //
    // Update counters
    //
    func checkCounters() {
        if (self.photoIndex >= 250) {
            self.photoIndex = 0
        } else {
            self.photoIndex++
        }
    }
    
    //
    // Helper function foe the cell, load data
    //
    func cellUrlHelper(photoIndex: Int!) -> PhotoComplete! {
        var photoObj: PhotoComplete?
        if (arrayDictionaryPhoto!.count > 0) {
            let urlHelper: UrlHelper = UrlHelper()
            photoObj = urlHelper.populatePhoto(arrayDictionaryPhoto![photoIndex])
        }
        return photoObj
    }
    
    
    //
    // Return to the collection view the max number of rows
    //
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
        if (photos?.count) > 0 {
            for tempPhoto: Photo in photos! {
                if (tempPhoto.id as Int) >= (greaterIDNumber as Int) {
                    greaterIDNumber = tempPhoto.id
                }
                // Now using prepare for deletion into entity
                // tempPhoto.posterImage = nil
                sharedContext.deleteObject(tempPhoto)
                do {
                    try sharedContext.save()
                } catch let error as NSError {
                    print("Error : \(error.localizedDescription)")
                }
            }
            photoIndex = greaterIDNumber as Int
            CoreDataStackManager.sharedInstance().saveContext()
        }
        
        
        // Change to false the line bellow and enable the second line to have option to select a picture
        // instead random
        helperObject.requestSearch(urlToCall: urlToCall, pin: pin, greaterID: greaterIDNumber as Int, controller: controller, contextManaged: contextManaged, completionHandler: { (result, error) -> Void in
            if let dataResultTemp = result {
                dispatch_async(dispatch_get_main_queue()) {
                    self.picturesGridCol.hidden = false
                    self.noImageLbl.hidden = true
                    self.newCollectionBtn.enabled = true
                    self.dataDictionary = dataResultTemp
                    self.jsonPhotos = self.dataDictionary!!["photos"] as? [String : AnyObject]
                    self.arrayDictionaryPhoto = self.jsonPhotos!["photo"] as? [[String : AnyObject]]
                    self.spinner.hide()
                    if (self.arrayDictionaryPhoto?.count < self.batchSize) {
                        self.batchSize = (self.arrayDictionaryPhoto?.count)!
                    } else {
                        self.batchSize = VTConstants.BATCH_SIZE  // Assign the value here to reload data just when I have the dictionary
                    }
                    self.picturesGridCol.reloadData()
                }
                
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.newCollectionBtn.enabled = true
                    //                    self.spinner.hide()
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
        isCallNewCollection = true
        newCollectionBtn.enabled = false
        spinner = ActivityIndicatorViewExt(text: VTConstants.PREPARING)
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
                // It's not needed add tempPhoto.posterImage = nil as it's been done into the Photo entity.
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
    
    
    
    //
    // Return the PhotoResult populated
    //
    func requestPhoto(photoObj: PhotoComplete?) ->(photoObject: Photo?, errorMessage: String?){
        var tempPhoto: Photo?
        
        if let _ = photoObj {
            let urlHelper: UrlHelper = UrlHelper()
            let urlToCall: String = urlHelper.assembleUrlToLoadImageFromSearch(photoObj!)
            
            let url: NSURL = NSURL(string: urlToCall)!
            if let imageData = NSData(contentsOfURL: url) {
                let imageTemp: UIImage? = UIImage(data: imageData)!
                
                if let _ = imageTemp {
                    let tempId: Int = photoIndex + 1
                    print("--- ID : \(tempId)")
                    let dictionary: [String: AnyObject] = [
                        Photo.Keys.ID : tempId,
                        Photo.Keys.photo : String("\(photoObj!.id!)_\(photoObj!.secret!).jpg")
                    ]
                    
                    print("\(photoObj!.id!)_\(photoObj!.secret!).jpg")
                    tempPhoto = Photo(photoDictionary: dictionary, context: sharedContext)
                    tempPhoto!.position = appDelegate.pinSelected
                    tempPhoto!.posterImage = imageTemp
                }
            }
            CoreDataStackManager.sharedInstance().saveContext()
            return (photoObject: tempPhoto, errorMessage: nil)
        } else {
            print("No Result Found")
            return (photoObject: nil, errorMessage: "No result Found!")
        }
    }
    
    
}
