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
    
    var studentCoordinates : CLLocationCoordinate2D? = nil
    
    // MARK : View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpForAddingLocationString()
        
        locationStringTextArea.text = "Vienna, Austria"
        
        // check if we have already an ObjectId
        if APIClient.sharedInstance.objectID == nil {
            APIClient.sharedInstance.queryStudentLocation([APIClient.StudentLocationKey.uniqueKey : APIClient.sharedInstance.userID]) {
                locations, error in
                if let errorMsg = error {
                } else {
                    let location = locations![0]
                    APIClient.sharedInstance.objectID = location.objectId
                    println("found objectID: \(location.objectId)")
                }
            }
        }
    }
    
    // MARK: IBActions
    
    
    @IBAction func findMapButtonTouchUp() {
        let locationString = locationStringTextArea.text
        
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(locationString) {
            placeMarks, error in
            
            if let errorMsg = error {
                println("Error forward geocoding: \(locationString)")
            } else if let placemark = placeMarks[0] as? CLPlacemark {
                let pointAnnotation = MKPointAnnotation()
                self.studentCoordinates = placemark.location.coordinate
                pointAnnotation.coordinate = self.studentCoordinates!
                pointAnnotation.title = locationString
                
                self.map!.addAnnotation(pointAnnotation)
                self.map!.centerCoordinate = pointAnnotation.coordinate
                self.map!.selectAnnotation(pointAnnotation, animated: true)
                
                println("forward geocoded: \(locationString) ")
                self.setUpForAddingLinkString()

            }
        }
    }
    
    @IBAction func submitButtonTouchUp() {
        // here we submit / update our location
        if let coordinates = studentCoordinates {
            var studentDict : [String : AnyObject] = [
                "lastName" : "Guerra",
                "firstName" : "Victor",
                "uniqueKey" : APIClient.sharedInstance.userID!,
                "mapString" : locationStringTextArea.text!,
                "mediaURL" : "http://blg.vg",
                "latitude" : coordinates.latitude,
                "longitude" : coordinates.longitude
            ]
            
            studentDict["objectId"] = (APIClient.sharedInstance.objectID == nil ? "" : APIClient.sharedInstance.objectID!)
            let studentLocation = StudentLocation(dict: studentDict)

            if let objectId = APIClient.sharedInstance.objectID {
                println("we go for PUT")
                APIClient.sharedInstance.putStudentLocation(studentLocation) {
                    error in
                    if let errorMsg = error {
                        println("error doing put: \(errorMsg)")
                    }
                }
            } else {
                println ("we go for POST")
                APIClient.sharedInstance.postStudentLocation(studentLocation) { objectId, error in
                    if let errorMsg = error {
                        println("error doing post: \(errorMsg)")
                    } else {
                        APIClient.sharedInstance.objectID = objectId
                    }
                }
            }
        }
    }
    
    // MARK : UI Elements manipulation
    
    // Step 1: Adding location string
    func setUpForAddingLocationString() {
        // All UI elements that need to be showed
        self.questionLabel.hidden = false
        self.locationStringTextArea.hidden = false
        self.findMapButton.hidden = false
        
        // All UI elements that need to be hidden
        self.personalLinkTextArea.hidden = true
        self.map.hidden = true
        self.submitButton.hidden = true
    }
    
    
    // Step 2: Adding link
    func setUpForAddingLinkString() {
        // All UI elements that need to be showed
        self.questionLabel.hidden = true
        self.locationStringTextArea.hidden = true
        self.findMapButton.hidden = true
        
        // All UI elements that need to be hidden
        self.personalLinkTextArea.hidden = false
        self.map.hidden = false
        self.submitButton.hidden = false
    }

}
