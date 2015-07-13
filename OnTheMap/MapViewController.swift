//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Victor Guerra on 16/06/15.
//  Copyright (c) 2015 Victor Guerra. All rights reserved.
//

import UIKit
import MapKit

class MapViewController : UIViewController, MKMapViewDelegate {

    @IBOutlet weak var map: MKMapView!
    
    override func  viewDidLoad() {
        super.viewDidLoad()
        
        addNavigationBar(self)
        self.navigationItem.title = "On The Map"

        APIClient.sharedInstance.getStudentLocations() { locations, error in
            
            if let locations = locations {
                var annotations = [MKAnnotation]()
                
                for location in locations {
                    let lat = CLLocationDegrees(location.latitude)
                    let long = CLLocationDegrees(location.longitude)
                    
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    
                    var annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    annotation.title = "\(location.firstName) \(location.lastName)"
                    annotation.subtitle = location.mediaURL
                    
                    // Finally we place the annotation in an array of annotations.
                    annotations.append(annotation)
                }
                self.map.addAnnotations(annotations)
            } else {
                println("Error getting locations \(error)")
            }
        }
    }
    
}
