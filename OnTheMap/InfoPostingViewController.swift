//
//  InfoPostingViewController.swift
//  OnTheMap
//
//  Created by Victor Guerra on 21/06/15.
//  Copyright (c) 2015 Victor Guerra. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class InfoPostingViewController : UIViewController {


    @IBOutlet weak var questionLabel: UILabel!
    
    
    @IBOutlet weak var locationStringTextArea: UITextView!
    @IBOutlet weak var personalLinkTextArea: UITextView!
    @IBOutlet weak var findMapButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var map: MKMapView!
    
    // MARK : View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpForAddingLocationString()
    }
    
    // MARK: IBActions
    
    
    @IBAction func findMapButtonTouchUp() {
        let locationString = "Vienna, Austria"
        
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(locationString) {
            placeMarks, error in
            
            if let errorMsg = error {
                println("Error forward geocoding: \(locationString)")
            } else if let placemark = placeMarks[0] as? CLPlacemark {
                let pointAnnotation = MKPointAnnotation()
                pointAnnotation.coordinate = placemark.location.coordinate
                pointAnnotation.title = placemark.description
                
                self.map!.addAnnotation(pointAnnotation)
                self.map!.centerCoordinate = pointAnnotation.coordinate
                self.map!.selectAnnotation(pointAnnotation, animated: true)
                
                println("forward geocoded: \(locationString) ")
                self.map!.hidden = false
            }
        }
    }
    
    @IBAction func submitButtonTouchUp() {
    }
    
    // MARK : UI Elements manipulation
    
    // Step 1: Adding location string
    func setUpForAddingLocationString() {
        // All UI elements that need to be showed
        questionLabel.hidden = false
        locationStringTextArea.hidden = false
        findMapButton.hidden = false
        
        // All UI elements that need to be hidden
        personalLinkTextArea.hidden = true
        map.hidden = true
        submitButton.hidden = true
        
    }
    
    
    // Step 2: Adding link
    func setUpForAddingLinkString() {
        // All UI elements that need to be showed
        questionLabel.hidden = true
        locationStringTextArea.hidden = true
        findMapButton.hidden = true
        
        // All UI elements that need to be hidden
        personalLinkTextArea.hidden = false
        map.hidden = false
        submitButton.hidden = false
    }

}
