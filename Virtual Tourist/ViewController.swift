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
    var spinner: ActivityIndicatorView!
    
    let reusableId: String = "pinInfo"
    var editingPins: Bool = false
    
    var filePath : String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
        return url.URLByAppendingPathComponent("mapRegionArchive").path!
    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        return fetchedResultsController
    }()
    
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
        
        do {
            try fetchedResultsController.performFetch()
        } catch {}
        
        
        fetchedResultsController.delegate = self
        
        navigationController?.setToolbarHidden(true, animated: true)
        checkForPins()
        restoreMapRegion(false)
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
    func handleLongTouch(getstureRecognizer : UIGestureRecognizer) {
        if getstureRecognizer.state == UIGestureRecognizerState.Began { return }
        
        //  If editing map, mean tapped on the edit navigation buttom
        if (editingPins == false) {
            let touchPoint = getstureRecognizer.locationInView(self.vtMapView)
            let touchMapCoordinate: CLLocationCoordinate2D = vtMapView.convertPoint(touchPoint, toCoordinateFromView: vtMapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchMapCoordinate
            
            let arrayLength: Int = appDelegate.pins.count
            let dictionary: [String: AnyObject] = [
                Pin.Keys.ID : arrayLength,
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
        spinner = ActivityIndicatorView(text: spinText)
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
        } else {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reusableId)
        }
        view.animatesDrop = true
        return view
    }
    
    
    
    //
    // check everytime that
    //
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if let _ = view.annotation {
            if (editingPins == true) {
                mapView.removeAnnotation(view.annotation!)
                let util: Utils = Utils()
                print("AppDelegate.pins \(appDelegate.pins)")
                
                let pinToRemove: Pin? = util.retrievePinFromArray(pinArray: appDelegate.pins as [Pin], pinToRemove: view.annotation!)!
                if let _ = pinToRemove {
                    appDelegate.pins = util.removePinFromArray(pinArray: appDelegate.pins, pinToRemove: view.annotation!)
                    sharedContext.deleteObject(pinToRemove!)
                }
            } else {
                // Add here the redirection to the next view.
                if let _ = appDelegate.pins {
                    let utils: Utils = Utils()
                    appDelegate.pinSelected = utils.retrievePinFromArray(pinArray: appDelegate.pins, pinToRemove: view.annotation!)
                    if let _ = appDelegate.pinSelected {
                        performSegueWithIdentifier("callPicGrid", sender: self)
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
            editingPins = true
            navigationItem.rightBarButtonItem?.title = "Done"
            navigationController?.setToolbarHidden(false, animated: true)
        } else {
            editingPins = false
            navigationItem.rightBarButtonItem?.title = "Edit"
            navigationController?.setToolbarHidden(true, animated: true)
        }
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
}

