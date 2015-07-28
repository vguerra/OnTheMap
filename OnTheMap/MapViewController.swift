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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if APIClient.sharedInstance.studentLocations == nil {
            self.refresh()
        } else {
            self.populateMap()
        }
    }
    
    // MARK: conforming to CommonNavigationBar protocol
    func refresh() {
        self.refreshLocationsWihtHandler() {
            self.populateMap()
        }
    }
    
    // Placing all pins on the map
    func populateMap() {
        if let studenLocations = APIClient.sharedInstance.studentLocations {
            var annotations : [MKAnnotation] = studenLocations.map() {
                let pAnnotation = MKPointAnnotation()
                pAnnotation.title = $0.title
                pAnnotation.subtitle = $0.mediaURL
                pAnnotation.coordinate = $0.coordinate
                return pAnnotation
            }
            dispatch_async(dispatch_get_main_queue()) {
                self.map.removeAnnotations(self.map.annotations)
                self.map.addAnnotations(annotations)
            }
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
            pinView!.animatesDrop = false
            pinView!.pinColor = .Red
            pinView!.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
}
