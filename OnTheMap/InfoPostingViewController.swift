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

class InfoPostingViewController : SLViewController, UITextFieldDelegate {

    @IBOutlet weak var question1Label: UILabel!
    @IBOutlet weak var question2Label: UILabel!
    @IBOutlet weak var question3Label: UILabel!
    
    @IBOutlet weak var personalLinkTextField: UITextField!
    @IBOutlet weak var locationStringTextField: UITextField!
    
    @IBOutlet weak var findMapButton: BorderedButton!
    @IBOutlet weak var submitButton: BorderedButton!
    @IBOutlet weak var cancelButton: BorderedButton!
    @IBOutlet weak var browseButton: BorderedButton!
    
    @IBOutlet weak var upperContainer: UIView!
    @IBOutlet weak var lowerContainer: UIView!
    @IBOutlet weak var locationContainer: UIView!
    
    @IBOutlet weak var map: MKMapView!
    
    var studentCoordinates : CLLocationCoordinate2D? = nil
    
    // MARK : View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        personalLinkTextField!.delegate = self
        locationStringTextField!.delegate = self
        configureUI()
        setUpForAddingLocationString()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    // MARK: IBActions
    @IBAction func cancelButtonTouchUp(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func browseButtonTouchUp(sender: AnyObject) {
        if personalLinkTextField.text.isEmpty {
            self.showWarning(title: "Hey, \(APIClient.sharedInstance.firstName)", message: "Enter a personal link please! ☺️")
        } else if !verifyUrl(personalLinkTextField.text) {
            self.showWarning(title: "That link seems wrong 😕", message: "Please enter a valid one ☺️")
        } else {
            self.openMediaURL(personalLinkTextField.text)
        }
    }
    
    @IBAction func findMapButtonTouchUp() {
        if locationStringTextField.text.isEmpty {
            self.showWarning(title: "Hey, \(APIClient.sharedInstance.firstName)", message: "Your location is need, please enter it 😉")
        } else {
            self.startActivityAnimation(message: "Geocoding location")
            let locationString = locationStringTextField.text
            
            let geoCoder = CLGeocoder()
            
            geoCoder.geocodeAddressString(locationString) {
                placeMarks, error in
                self.stopActivityAnimation()
                if let errorMsg = error {
                    self.showWarning(title: "Sorry! geocoding did not work. 😕",
                        message: "Probably the location you entered is invalid, Try again please! 😉")
                } else if let placemark = placeMarks[0] as? CLPlacemark {
                    let pointAnnotation = MKPointAnnotation()
                    self.studentCoordinates = placemark.location.coordinate
                    pointAnnotation.coordinate = self.studentCoordinates!
                    pointAnnotation.title = locationString
                    
                    self.map!.addAnnotation(pointAnnotation)
                    self.map!.centerCoordinate = pointAnnotation.coordinate
                    self.map!.selectAnnotation(pointAnnotation, animated: true)
                    
                    self.setUpForAddingLinkString()
                }
            }
        }
    }
    
    @IBAction func submitButtonTouchUp() {
        if personalLinkTextField.text.isEmpty {
            self.showWarning(title: "Hey, \(APIClient.sharedInstance.firstName)", message: "Your fellow students would like to know about you, enter a personal link please! ☺️")
        } else if !verifyUrl(personalLinkTextField.text) {
            self.showWarning(title: "That link seems wrong 😕", message: "Please enter a valid one ☺️")
        } else {
            self.startActivityAnimation(message: "Sending location")
            if let coordinates = studentCoordinates {
                var studentDict : [String : AnyObject] = [
                    APIClient.StudentLocationKey.lastName : APIClient.sharedInstance.lastName,
                    APIClient.StudentLocationKey.firstName : APIClient.sharedInstance.firstName,
                    APIClient.StudentLocationKey.uniqueKey : APIClient.sharedInstance.userID!,
                    APIClient.StudentLocationKey.mapString : locationStringTextField.text!,
                    APIClient.StudentLocationKey.mediaURL : personalLinkTextField.text!,
                    APIClient.StudentLocationKey.latitude : coordinates.latitude,
                    APIClient.StudentLocationKey.longitude : coordinates.longitude
                ]
                
                studentDict["objectId"] = (APIClient.sharedInstance.objectID == nil ? "" : APIClient.sharedInstance.objectID!)
                let studentLocation = StudentLocation(dict: studentDict)
                
                var sendinLocationError = false
                if let objectId = APIClient.sharedInstance.objectID {
                    APIClient.sharedInstance.putStudentLocation(studentLocation) {
                        error in
                        self.stopActivityAnimation()
                        if let errorMsg = error {
                            self.showWarning(title: "Updating location didn't work 😞", message: errorMsg.localizedDescription)
                            sendinLocationError = true
                        }
                    }
                } else {
                    APIClient.sharedInstance.postStudentLocation(studentLocation) { objectId, error in
                        if let errorMsg = error {
                            self.stopActivityAnimation()
                            self.showWarning(title: "Sending location didn't work 😞", message: errorMsg.localizedDescription)
                            sendinLocationError = true
                        } else {
                            APIClient.sharedInstance.objectID = objectId
                        }
                    }
                }
                
                if !sendinLocationError {
                    APIClient.sharedInstance.getStudentLocations() { locations, error in
                        self.stopActivityAnimation()
                        if let errorMsg = error {
                            self.showWarning(title: "Getting Student locations didn't work 😞", message: errorMsg.localizedDescription)
                        } else {
                            self.dismissViewControllerAnimated(true, completion: nil)
                        }
                    }
                }
            }
        }
    }
    
    // Keeping the text within the textViews centered horizontally and vertically
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if let textView = object as? UITextView {
            var y: CGFloat = (textView.bounds.size.height - textView.contentSize.height * textView.zoomScale)/2.0;
            if y < 0 {
                y = 0
            }
            textView.contentOffset = CGPoint(x: 0, y: -y)
        }
    }

    // MARK : UI Elements manipulation/configuration
    // Step 1: Adding location string
    func setUpForAddingLocationString() {
        // All UI elements that need to be showed
        self.question1Label.hidden = false
        self.question2Label.hidden = false
        self.question3Label.hidden = false
        self.locationStringTextField.hidden = false
        self.findMapButton.hidden = false
        self.locationContainer.hidden = false
        
        // All UI elements that need to be hidden
        self.personalLinkTextField.hidden = true
        self.map.hidden = true
        self.submitButton.hidden = true
        self.browseButton.hidden = true
        
        upperContainer.backgroundColor = UIColor(red: 0.850, green: 0.850, blue: 0.850, alpha: 1.0)
    }
    
    
    // Step 2: Adding link
    func setUpForAddingLinkString() {
        // All UI elements that need to be showed
        self.question1Label.hidden = true
        self.question2Label.hidden = true
        self.question3Label.hidden = true
        self.locationStringTextField.hidden = true
        self.findMapButton.hidden = true
        self.locationContainer.hidden = true
        
        // All UI elements that need to be hidden
        self.personalLinkTextField.hidden = false
        self.map.hidden = false
        self.submitButton.hidden = false
        self.browseButton.hidden = false
        
        upperContainer.backgroundColor = UIColor(red: 0.250, green: 0.450, blue: 0.660, alpha: 1.0)
    }
    
    func configureUI() {
        let blueColor = UIColor(red: 0.250, green: 0.450, blue: 0.660, alpha: 1.0)
        let whiteColor = UIColor.whiteColor()
        let grayColor = UIColor(red: 0.850, green: 0.850, blue: 0.850, alpha: 1.0)
    
    
        lowerContainer.backgroundColor = grayColor
        upperContainer.backgroundColor = grayColor
        locationContainer.backgroundColor = blueColor
        
        // buttons
        findMapButton.titleLabel?.font = UIFont(name: "Roboto-Medium", size: 16.0)
        findMapButton.setTitleColor(blueColor, forState: UIControlState.Normal)
        findMapButton.backgroundColor = whiteColor
        findMapButton.backingColor = whiteColor
        findMapButton.highlightedBackingColor = whiteColor

        submitButton.titleLabel?.font = UIFont(name: "Roboto-Medium", size: 16.0)
        submitButton.setTitleColor(blueColor, forState: UIControlState.Normal)
        submitButton.backgroundColor = whiteColor
        submitButton.backingColor = whiteColor
        submitButton.highlightedBackingColor = whiteColor

        browseButton.titleLabel?.font = UIFont(name: "Roboto-Medium", size: 16.0)
        browseButton.setTitleColor(blueColor, forState: UIControlState.Normal)
        browseButton.backgroundColor = whiteColor
        browseButton.backingColor = whiteColor
        browseButton.highlightedBackingColor = whiteColor

        cancelButton.titleLabel?.font = UIFont(name: "Roboto-Medium", size: 16.0)
        cancelButton.setTitleColor(blueColor, forState: UIControlState.Normal)
        cancelButton.backgroundColor = whiteColor
        cancelButton.backingColor = whiteColor
        cancelButton.highlightedBackingColor = whiteColor

        // labels
        question1Label.textColor = blueColor
        question1Label.font = UIFont(name: "Roboto-Thin", size: 20.0)
        question2Label.textColor = blueColor
        question2Label.font = UIFont(name: "Roboto-Medium", size: 20.0)
        question3Label.textColor = blueColor
        question3Label.font = UIFont(name: "Roboto-Thin", size: 20.0)
        
        // TextFields
        locationStringTextField.backgroundColor = blueColor
        locationStringTextField.textColor = whiteColor
        locationStringTextField.font = UIFont(name: "Roboto-Medium", size: 18.0)
        locationStringTextField.tintColor = whiteColor
        locationStringTextField.attributedPlaceholder = NSAttributedString(string: locationStringTextField.placeholder!, attributes: [NSForegroundColorAttributeName: grayColor])

        personalLinkTextField.backgroundColor = blueColor
        personalLinkTextField.textColor = whiteColor
        personalLinkTextField.font = UIFont(name: "Roboto-Medium", size: 18.0)
        personalLinkTextField.tintColor = whiteColor
        personalLinkTextField.attributedPlaceholder = NSAttributedString(string: personalLinkTextField.placeholder!, attributes: [NSForegroundColorAttributeName: grayColor])
    }
    
    // Small helper to verify valid URLs
    func verifyUrl(urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = NSURL(string: urlString) {
                return UIApplication.sharedApplication().canOpenURL(url)
            }
        }
        return false
    }

    // MARK: conforming to UITextField Delegate protocol
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
}

