//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Klaus Villaca on 12/5/15.
//  Copyright © 2015 Klaus Villaca. All rights reserved.
//
//  First view.
//  I didn't rename it as XCode still don't refactor SWIFT code
//
//

import UIKit
import MapKit
import CoreData

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, NSFetchedResultsControllerDelegate {
    
    
    @IBOutlet weak var editBtn: UIBarButtonItem!
    @IBOutlet weak var vtMapView: MKMapView!
    
    
    var appDelegate: AppDelegate!
    var spinner: ActivityIndicatorViewExt!
    
    let reusableId: String = "pinInfo"
    var editingPins: Bool = false
    
    // Get the file path
    var filePath : String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
        return url.URLByAppendingPathComponent("mapRegionArchive").path!
    }
    
    // Create the shared context
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    
    //
    // Function called when view did load
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vtMapView.delegate = self
        appDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        
        appDelegate.pins = [Pin]()
        
        // Add the touch listener
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: "handleLongTouch:")
        longPressRecogniser.minimumPressDuration = 0.8
        vtMapView.addGestureRecognizer(longPressRecogniser)
        
        navigationController?.setToolbarHidden(true, animated: true)
        
        poulatePinArray()
        checkForPins()
        restoreMapRegion(false)
    }
    
    
    //
    // Populate the Pin array from the DB
    //
    func poulatePinArray() {
        if appDelegate.pins == nil || appDelegate.pins!.count == 0 {
            appDelegate.pins = [Pin]()
        }
        do {
            let fetchRequest = NSFetchRequest(entityName: Pin.Keys.PinClass)
            fetchRequest.returnsObjectsAsFaults = false
            let tempPinArray: [Pin] = try sharedContext.executeFetchRequest(fetchRequest) as! [Pin]
            if (tempPinArray.count > 0) {
                for result: Pin in tempPinArray {
                    appDelegate.pins.append(result)
                }
            }
            
            // This message is intented to be displayed if there is none or zero pin.
            if appDelegate.pins.count == 0 {
                Dialog().okDismissAlert(titleStr: VTConstants.ADD_PIN, messageStr: VTConstants.ADD_PIN_MESSAGE, controller: self)
            }
        } catch let error as NSError {
            Dialog().okDismissAlert(titleStr: VTConstants.ERROR, messageStr: error.localizedDescription, controller: self)
            print("Error : \(error.localizedDescription)")
        }
    }
    
    
    //
    // Check if exist pins, if does then loop through it and populate the map
    //
    func checkForPins() {
        if let _ = appDelegate.pins {
            for (_, element) in appDelegate.pins.enumerate() {
                let tempPin: Pin = element
                let utils: Utils = Utils()
                let annotationTempAdd: MKPointAnnotation = utils.retrieveAnnotation(latitude: Double(tempPin.latitude), longitude: Double(tempPin.longitude))
                vtMapView.addAnnotation(annotationTempAdd)
            }
        }
    }
    
    
    //
    // Handle the tap touch
    //
    func handleLongTouch(gestureRecognizer : UIGestureRecognizer) {
        if (editingPins == false) {
            if gestureRecognizer.state == UIGestureRecognizerState.Began {
                return
            }
        }
        
        //  If editing map, mean tapped on the edit navigation buttom
        if (editingPins == false && gestureRecognizer.state == UIGestureRecognizerState.Ended) {
            let touchPoint = gestureRecognizer.locationInView(self.vtMapView)
            let touchMapCoordinate: CLLocationCoordinate2D = vtMapView.convertPoint(touchPoint, toCoordinateFromView: vtMapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchMapCoordinate
            
            let arrayLength: Int = appDelegate.pins.count
            let dictionary: [String: AnyObject] = [
                Pin.Keys.ID : arrayLength + 1,
                Pin.Keys.latitude : annotation.coordinate.latitude as Double,
                Pin.Keys.longitude : annotation.coordinate.longitude as Double,
                Pin.Keys.photos : [Photo]()
            ]
            
            let pinTemp: Pin = Pin(photoDictionary: dictionary, context: sharedContext)
            CoreDataStackManager.sharedInstance().saveContext()
            vtMapView.addAnnotation(annotation)
            appDelegate.pins.append(pinTemp)
        }
    }
    
    
    //
    // Add view to show the spin
    //
    func startSpin(spinText spinText: String) {
        spinner = ActivityIndicatorViewExt(text: spinText)
        view.addSubview(spinner)
    }
    
    
    //
    // Check for annotations for display
    //
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is MKPointAnnotation) {
            return nil
        }
        
        var view: MKPinAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(reusableId) as? MKPinAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
            view.animatesDrop = false
        } else {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reusableId)
            view.animatesDrop = true
        }
        return view
    }
    
    
    //
    // Check everytime that the user tap on top of an Pin annotation, if not in edit mode, than it will redirect the
    // to the next view, if in edit mode then delete the pin fmor view and DB
    //
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        if let _ = view.annotation {
            // Delete or redirect to the next view
            if (editingPins == true) {
                let utils: Utils = Utils()
                let isDeleted: Bool = utils.removePin(pinArray: appDelegate.pins as [Pin], pinAnnotation: view.annotation!, sharedContext: sharedContext, controller: self)
                
                if isDeleted {
                    appDelegate.pins = utils.removePinFromArray(pinArray: appDelegate.pins, pinToRemove: view.annotation!)
                    CoreDataStackManager.sharedInstance().saveContext()
                    Dialog().timedDismissAlert(titleStr: VTConstants.DELETE, messageStr: VTConstants.DELETED_MESSAGE, secondsToDismmis: 2, controller: self)
                    mapView.removeAnnotation(view.annotation!)
                }
            } else {
                // Add here the redirection to the next view.
                if let _ = appDelegate.pins {
                    let utils: Utils = Utils()
                    appDelegate.pinSelected = utils.retrievePinFromArray(pinArray: appDelegate.pins, pinToRemove: view.annotation!)
                    if let _ = appDelegate.pinSelected {
                        performSegueWithIdentifier("callPicGrid", sender: self)
                        vtMapView.deselectAnnotation(view.annotation, animated: false)
                    }
                }
            }
        }
    }
    
    
    //
    // Save the Map region
    //
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // Place the "center" and "span" of the map into a dictionary
        // The "span" is the width and height of the map in degrees.
        // It represents the zoom level of the map.
        
        let dictionary = [
            "latitude" : vtMapView.region.center.latitude,
            "longitude" : vtMapView.region.center.longitude,
            "latitudeDelta" : vtMapView.region.span.latitudeDelta,
            "longitudeDelta" : vtMapView.region.span.longitudeDelta
        ]
        
        // Archive the dictionary into the filePath
        NSKeyedArchiver.archiveRootObject(dictionary, toFile: filePath)
    }
    
    
    //
    // Edit button that change to done and vice versa
    //
    @IBAction func editBtn(sender: AnyObject) {
        if (!editingPins) {
            vtMapView.setNeedsFocusUpdate()
            editingPins = true
            navigationItem.rightBarButtonItem?.title = "Done"
            navigationController?.setToolbarHidden(false, animated: true)
        } else {
            editingPins = false
            navigationItem.rightBarButtonItem?.title = "Edit"
            navigationController?.setToolbarHidden(true, animated: true)
        }
        vtMapView.updateFocusIfNeeded()
    }
    
    
    //
    // Function to restore the Map Region
    //
    func restoreMapRegion(animated: Bool) {
        // if we can unarchive a dictionary, we will use it to set the map back to its
        // previous center and span
        if let regionDictionary = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? [String : AnyObject] {
            let longitude = regionDictionary["longitude"] as! CLLocationDegrees
            let latitude = regionDictionary["latitude"] as! CLLocationDegrees
            let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            let longitudeDelta = regionDictionary["latitudeDelta"] as! CLLocationDegrees
            let latitudeDelta = regionDictionary["longitudeDelta"] as! CLLocationDegrees
            let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
            
            let savedRegion = MKCoordinateRegion(center: center, span: span)
            vtMapView.setRegion(savedRegion, animated: animated)
        }
    }
    
    
//    //
//    // Remove all those cached images belonging to the pin.
//    //
//    func removeCachedImages(cachedImagesToRemove: NSSet) {
//        let tempPhotos: [Photo] = cachedImagesToRemove.allObjects as NSArray as! [Photo]
//        for tempPhoto: Photo in tempPhotos {
//            // The line bellow is actually removing the photo, now using prepareToDelete
//            // tempPhoto.posterImage = nil
//            sharedContext.deleteObject(tempPhoto)
//        }
//        
//        do {
//            try sharedContext.save()
//            CoreDataStackManager.sharedInstance().saveContext()
//            Dialog().timedDismissAlert(titleStr: VTConstants.DELETE, messageStr: VTConstants.DELETED_MESSAGE, secondsToDismmis: 2, controller: self)
//        } catch let error as NSError {
//            Dialog().okDismissAlert(titleStr: VTConstants.ERROR, messageStr: error.localizedDescription, controller: self)
//        }
//        
//    }
}

