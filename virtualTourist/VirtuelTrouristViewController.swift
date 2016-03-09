//
//  ViewController.swift
//  virtualTourist
//
//  Created by Anas Belkhadir on 19/12/2015.
//  Copyright © 2015 Anas Belkhadir. All rights reserved.
//

import UIKit
import MapKit
import CoreData




class VirtuelTrouristViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    //later convert to core data just testing

    var pins = [Pin]()
    
    var annotationPoint = MKPointAnnotation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpRecognizer()
        mapView.delegate = self
        
        pins = fetchAllPins()
        let _ = pins.map(){ (pin:Pin) -> MKPointAnnotation in
            let latitude = pin.latitude
            let longitude = pin.longitude
            let annotation = MKPointAnnotation()
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            annotation.coordinate = coordinate
            self.mapView.addAnnotation(annotation)
            return annotation   
            
        }

    }
    
    func setUpRecognizer(){
        let tapGesture = UILongPressGestureRecognizer(target: self, action: "addAnnotationUsingRecognizer:")
        tapGesture.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(tapGesture)
    }
    
    func fetchAllPins() -> [Pin] {
        let fetchedRequest = NSFetchRequest(entityName: "Pin")
     
        do {
            return try sharedContext.executeFetchRequest(fetchedRequest) as! [Pin]
        }catch {
            return  [Pin]()
        }
    }
    
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    
    func addAnnotationUsingRecognizer(recognizer: UITapGestureRecognizer){
        
        let touchPoint:CGPoint = recognizer.locationInView(mapView)
    
        switch recognizer.state {
            
        case .Began :
                let touchPointToCLLocation = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
                annotationPoint.coordinate = touchPointToCLLocation
                annotationPoint.title = "my home"
                mapView.addAnnotation(annotationPoint)
        
        case .Changed:
                let touchPointToCLLocation = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
                annotationPoint.coordinate = touchPointToCLLocation
            
        case .Ended :
    
            let dictionary: [String: AnyObject] = [
                    Pin.key.longitude: annotationPoint.coordinate.longitude ,
                    Pin.key.latitude: annotationPoint.coordinate.latitude
            ]
            
            let pin = Pin(dictionary: dictionary, context: self.sharedContext)
            self.pins.append(pin)
            self.saveContext()
            mapView.addAnnotation(annotationPoint)
            let DPVC = storyboard!.instantiateViewControllerWithIdentifier("displayPhoto") as! DisplayPhotoViewController
            DPVC.annotation  = self.annotationPoint
            DPVC.pin = pin
            presentViewController(DPVC, animated: true, completion: nil)
        case .Cancelled:
            break
         
        case .Failed:
            break
            
        case .Possible: break
        
        }
        
    }

    

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Red
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let DPVC = storyboard?.instantiateViewControllerWithIdentifier("displayPhoto") as! DisplayPhotoViewController
            DPVC.annotation  = self.annotationPoint
            presentViewController(DPVC, animated: true, completion: nil)
        }
    }
    

}

