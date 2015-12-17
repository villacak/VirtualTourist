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

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    
    @IBOutlet weak var editBtn: UIBarButtonItem!
    @IBOutlet weak var vtMapView: MKMapView!
    
    
    var appDelegate: AppDelegate!
    
    var spinner: ActivityIndicatorView!
    
    let reusableId: String = "pinInfo"
    
    var editingPins: Bool = false
    
    //
    // Function called when view did load
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vtMapView.delegate = self
        appDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        
        // Add the long touch to the map
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: "handleLongTouch:")
        longPressRecogniser.minimumPressDuration = 1.0
        vtMapView.addGestureRecognizer(longPressRecogniser)
        
        
        navigationController?.setToolbarHidden(true, animated: true)
        
        checkForPins()
    }
    

    
    //
    // Function called when receiving a memory warning
    //
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    //
    // Check if exist pins, if does then loop through it and populate the map
    //
    func checkForPins() {
        if let _ = appDelegate.pins {
            for (_, element) in appDelegate.pins.enumerate() {
                vtMapView.addAnnotation(element.position)
            }
        }
    }
    
    
    //
    // Handle the long touch
    //
    func handleLongTouch(getstureRecognizer : UIGestureRecognizer){
        if getstureRecognizer.state != .Began { return }
        
        let touchPoint = getstureRecognizer.locationInView(self.vtMapView)
        let touchMapCoordinate = vtMapView.convertPoint(touchPoint, toCoordinateFromView: vtMapView)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = touchMapCoordinate
        
        if let _ = appDelegate.pins {
            let arrayLength: Int = appDelegate.pins.count
            let pinTemp: Pin = Pin(id: arrayLength, position: annotation, photos: [Photo]())
            appDelegate.pins.append(pinTemp)
        }
        
        vtMapView.addAnnotation(annotation)
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
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: UIButtonType.DetailDisclosure) as UIView
        }
        view.animatesDrop = true
        return view
    }

    
    //
    // Remove pin
    //
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            
        }
    }

    
    @IBAction func editBtn(sender: AnyObject) {
        if (!editingPins) {
            editingPins = true
            navigationItem.rightBarButtonItem?.title = "Done"
//            bottomView.hidden = false
//            toolBarText.hidden = false
            navigationController?.setToolbarHidden(false, animated: true)
        } else {
            editingPins = false
            navigationItem.rightBarButtonItem?.title = "Edit"
//            bottomView.hidden = true
//            toolBarText.hidden = true
            navigationController?.setToolbarHidden(true, animated: true)
        }
    }
    
    
}

