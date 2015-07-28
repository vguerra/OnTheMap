//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Victor Guerra on 16/06/15.
//  Copyright (c) 2015 Victor Guerra. All rights reserved.
//

import UIKit
import MapKit

class MapViewController : SLViewController, MKMapViewDelegate, CommonNavigationBar {

    @IBOutlet weak var map: MKMapView!
    
    // MARK: ViewController life cycle
    override func  viewDidLoad() {
        super.viewDidLoad()
        addNavigationBar(self)
        self.navigationItem.title = "On The Map"
        map.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if APIClient.sharedInstance.studentLocations == nil {
            self.refresh()
        } else {
            self.populateMap()
        }
    }
    
    // MARK: conforming to CommonNavigationBar protocol
    func refresh() {
        refreshLocationsWihtHandler() {
            self.populateMap()
        }
    }
    
    // Placing all pins on the map
    func populateMap() {
        var annotations = [MKAnnotation]()
        for location in APIClient.sharedInstance.studentLocations! {
            let lat = CLLocationDegrees(location.latitude)
            let long = CLLocationDegrees(location.longitude)
            
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            var annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(location.firstName) \(location.lastName)"
            annotation.subtitle = location.mediaURL
            
            annotations.append(annotation)
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            self.map.removeAnnotations(self.map.annotations)
            self.map.addAnnotations(annotations)
        }
    }
    
    func showInfoPostingView () {
        self.locationOverwrite()
    }
    
    func logOut() {
        logOutApp()
    }
    
    // MARK: Conforming to MKMapViewDelegate
    func mapView(mapView: MKMapView!, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == annotationView.rightCalloutAccessoryView {
            openMediaURL(annotationView.annotation.subtitle!)
        }
    }

    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Red
            pinView!.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
}
