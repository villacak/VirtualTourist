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
    var spinner: ActivityIndicatorViewExt!
    var urlHelper: UrlHelper!
    
    var batchSize: Int = 0
    var photoIndex: Int = 0
    var isJustLoad: Bool = false
    var greatestId: Int = 0
    
    var jsonPhotos: [String : AnyObject]? = [String : AnyObject]()
    var arrayDictionaryPhoto: [[String : AnyObject]]? = [[String : AnyObject]]()
    var inMemoryCache = NSCache()
    
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
                isJustLoad = true
                callNewCollection()
                picturesGridCol.hidden = false
                noImageLbl.hidden = true
                batchSize = VTConstants.BATCH_SIZE
            } else {
                isJustLoad = false
                photos = [Photo]()
                defaultSettingsForEmptyArray()
            }
        } else {
            isJustLoad = false
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
        photos?.removeAll()
        appDelegate.pinSelected = nil
        arrayDictionaryPhoto?.removeAll()
        jsonPhotos?.removeAll()
    }
    
    
    //
    // Return the count value that has the amount of items within the array
    //
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return batchSize
    }
    
    
    //
    // Loop through each item to display it
    //
    // Should have a more ellegant way to work this out, I don't really like how this async tasks and completionHandlers work
    //
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let reusedIdentifier = "PictureSecondView"
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reusedIdentifier, forIndexPath: indexPath) as! PinCollectionViewCell
        cell.imageViewTableCell?.layer.borderWidth = 1.0
        cell.imageViewTableCell?.layer.borderColor = UIColor.blackColor().CGColor
        cell.labelCell?.text = "\(indexPath.row)"
        cell.cellSpinner.startAnimating()
        
        print("indexPath.row \(indexPath.row)")
        
        var localId: Int = indexPath.row
        if (greatestId >= batchSize) {
            localId = greatestId + indexPath.row
        }
        if (photos!.count > 0 && photos?.count > indexPath.row) {
            let photoTemp = self.photos?[indexPath.row]
            cell.cellSpinner.stopAnimating()
            if let imageTemp = photoTemp!.posterImage {
                cell.imageViewTableCell?.image = imageTemp
            } else {
                loadImageAsync(localId, completionHandler: { (result, error) -> Void in
                    if let _ = result {
                        dispatch_async(dispatch_get_main_queue()) {
                            cell.cellSpinner.hidden = true
                            cell.imageViewTableCell?.image = result
                            cell.cellSpinner.stopAnimating()
                        }
                    }
                    
                })
            }
        } else {
            loadImageAsync(localId, completionHandler: { (result, error) -> Void in
                if let _ = result {
                    dispatch_async(dispatch_get_main_queue()) {
                        cell.cellSpinner.hidden = true
                        cell.imageViewTableCell?.image = result
                        cell.cellSpinner.stopAnimating()
                    }
                }
            })
        }
        return cell
    }
    
    
    //
    // Load images asynchronous
    //
    func loadImageAsync(indexToLoad: Int!, completionHandler:(result: UIImage?, error: String?) -> Void) {
        let tempPhotoComplete: PhotoComplete = cellUrlHelper(indexToLoad)
        let urlToCall: String = self.urlHelper.assembleUrlToLoadImageFromSearch(tempPhotoComplete)
        let url: NSURL = NSURL(string: urlToCall)!
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
            if let imageData = NSData(contentsOfURL: url) {
                let imageTemp: UIImage? = UIImage(data: imageData)!
                
                dispatch_barrier_async(dispatch_get_main_queue(), {() -> Void in
                    self.requestPhoto(tempPhotoComplete, imageTemp: imageTemp, indexId: indexToLoad)
                    self.picturesGridCol.reloadData()
                    completionHandler(result: imageTemp, error: nil)
                })
            }
        })
    }
    
    
    //
    // Helper function foe the cell, load data
    //
    func cellUrlHelper(cellPhotoIndex: Int!) -> PhotoComplete! {
        var photoObj: PhotoComplete?
        if (arrayDictionaryPhoto!.count > 0) {
            let urlHelper: UrlHelper = UrlHelper()
            photoObj = urlHelper.populatePhoto(arrayDictionaryPhoto![cellPhotoIndex])
            
            // Remove the photo from array to avoid duplicated photos.
            arrayDictionaryPhoto?.removeAtIndex(cellPhotoIndex)
            print("ArrayDicPhoto counter \(arrayDictionaryPhoto?.count)")
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
        if (photos?.count) > 0 && !isJustLoad{
            for tempPhoto: Photo in photos! {
                let photoId: Int = tempPhoto.id as Int
                if (photoId > greatestId) {
                    greatestId = photoId
                }
                sharedContext.deleteObject(tempPhoto)
                do {
                    try sharedContext.save()
                } catch let error as NSError {
                    // Should add a timed dialog over here???
                    print("Error : \(error.localizedDescription)")
                }
            }
            CoreDataStackManager.sharedInstance().saveContext()
            photos?.removeAll()
            
            if greatestId == 250 {
                greatestId = 0
            }
            
            self.newCollectionBtn.enabled = true
            if (!self.isJustLoad) {
                self.spinner.hide()
            }
            self.picturesGridCol.reloadData()
        }
        
        if (arrayDictionaryPhoto!.count) == 0 {
            // Change to false the line bellow and enable the second line to have option to select a picture
            // instead random
            helperObject.requestSearch(urlToCall: urlToCall, pin: pin, controller: controller, contextManaged: contextManaged, completionHandler: { (result, error) -> Void in
                if let dataResultTemp = result {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.picturesGridCol.hidden = false
                        self.noImageLbl.hidden = true
                        self.newCollectionBtn.enabled = true
                        self.dataDictionary = dataResultTemp
                        self.jsonPhotos = self.dataDictionary!!["photos"] as? [String : AnyObject]
                        self.arrayDictionaryPhoto = self.jsonPhotos!["photo"] as? [[String : AnyObject]]
                        
                        if (!self.isJustLoad) {
                            self.spinner.hide()
                        }
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
                        self.spinner.hide()
                        Dialog().okDismissAlert(titleStr: VTConstants.ERROR, messageStr: error!, controller: controller)
                    }
                }
                
            })
        }
    }
    
    
    //
    // New Collection Button
    //
    @IBAction func newCollectionBtn(sender: AnyObject) {
        isJustLoad = false
        callNewCollection()
    }
    
    
    //
    // Make the call for load a new collection
    //
    func callNewCollection() {
        urlHelper = UrlHelper()
        newCollectionBtn.enabled = false
        
        if (!isJustLoad) {
            spinner = ActivityIndicatorViewExt(text: VTConstants.PREPARING)
            view.addSubview(spinner)
        }
        
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
                Dialog().timedDismissAlert(titleStr: VTConstants.DELETE, messageStr: VTConstants.DELETED_SINGLE_PIC, secondsToDismmis: 1, controller: self)
                CoreDataStackManager.sharedInstance().saveContext()
                photos?.removeAtIndex(photoIndexForDelete)
                batchSize-- // Need to reduce the batch size to don't have problem when scrolling photos
                self.picturesGridCol.reloadData()
                
                if (photos?.count == 0) {
                    removePin()
                    
                    // Set a flag to re-populate pins in the map from previous view
                    let defaults = NSUserDefaults.standardUserDefaults()
                    defaults.setObject(true, forKey: VTConstants.DEFAULT_KEY)
                    
                    // Return to the previous view as doesn't have photos anymore
                    // It's needed to hold a bit to the Dialog be dimissed to then return
                    let delay = 1.5 * Double(NSEC_PER_SEC)
                    let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                    dispatch_after(time, dispatch_get_main_queue(), {
                        self.navigationController?.popToRootViewControllerAnimated(true)
                    })
                }
            } catch let error as NSError {
                Dialog().okDismissAlert(titleStr: VTConstants.ERROR, messageStr: error.localizedDescription, controller: self)
            }
        }
    }
    
    
    
    //
    // Remove Pin and also remove the pin from the array
    //
    func removePin() {
        let utils: Utils = Utils()
        let annotationPoint: MKPointAnnotation = MKPointAnnotation()
        annotationPoint.coordinate.latitude = appDelegate.pinSelected?.latitude as! Double
        annotationPoint.coordinate.longitude = appDelegate.pinSelected?.longitude as! Double
        
        
        let isDeleted: Bool = utils.removePin(pinArray: appDelegate.pins as [Pin], pinAnnotation: annotationPoint, sharedContext: sharedContext, controller: self)
        
        if isDeleted {
            appDelegate.pins = utils.removePinFromArray(pinArray: appDelegate.pins, pinToRemove: annotationPoint)
            CoreDataStackManager.sharedInstance().saveContext()
            Dialog().timedDismissAlert(titleStr: VTConstants.DELETE, messageStr: VTConstants.DELETED_MESSAGE, secondsToDismmis: 1, controller: self)
        }
    }
    
    
    //
    // Return the PhotoResult populated
    //
    func requestPhoto(photoObj: PhotoComplete!, imageTemp: UIImage!, indexId: Int!) {
        var tempPhoto: Photo?
        
        if let _ = photoObj {
            if let _ = imageTemp {
                let tempId: Int = indexId + 1  // For some reason indexId++ was giving me error
                print("--- ID : \(tempId)")
                let dictionary: [String: AnyObject] = [
                    Photo.Keys.ID : tempId,
                    Photo.Keys.photo : String("\(photoObj!.id!)_\(photoObj!.secret!).jpg")
                ]
                
                tempPhoto = Photo(photoDictionary: dictionary, context: sharedContext)
                tempPhoto!.position = appDelegate.pinSelected
                tempPhoto!.posterImage = imageTemp
                
                photos?.append(tempPhoto!)
                CoreDataStackManager.sharedInstance().saveContext()
            }
        }
    }
    
}
