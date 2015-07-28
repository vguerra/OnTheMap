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

class InfoPostingViewController : SLViewController, UITextViewDelegate {

    @IBOutlet weak var question1Label: UILabel!
    @IBOutlet weak var question2Label: UILabel!
    @IBOutlet weak var question3Label: UILabel!
    
    @IBOutlet weak var personalLinkTextArea: UITextView!
    @IBOutlet weak var locationStringTextArea: UITextView!
    @IBOutlet weak var findMapButton: BorderedButton!
    @IBOutlet weak var submitButton: BorderedButton!
    @IBOutlet weak var cancelButton: BorderedButton!
    
    @IBOutlet weak var upperContainer: UIView!
    @IBOutlet weak var lowerContainer: UIView!
    @IBOutlet weak var map: MKMapView!
    
    var studentCoordinates : CLLocationCoordinate2D? = nil
    
    // Text used as placeholders for the Text areas
    let personalLinkPlaceholder = "Enter a Link to share here"
    let locationStringPlaceholder = "Enter your Location here"
    
    // MARK : View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        setUpForAddingLocationString()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        applyPlaceholderStyle(personalLinkTextArea, placeholderText: personalLinkPlaceholder)
        applyPlaceholderStyle(locationStringTextArea, placeholderText: locationStringPlaceholder)
        
        locationStringTextArea.addObserver(self, forKeyPath: "contentSize", options: .New, context: nil)
        personalLinkTextArea.addObserver(self, forKeyPath: "contentSize", options: .New, context: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        locationStringTextArea.removeObserver(self, forKeyPath: "contentSize")
        personalLinkTextArea.removeObserver(self, forKeyPath: "contentSize")
    }
    
    
    // MARK: IBActions
    @IBAction func cancelButtonTouchUp(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func findMapButtonTouchUp() {
        if locationStringTextArea.text == locationStringPlaceholder || locationStringTextArea.text.isEmpty {
            self.showWarning(title: "Hey, \(APIClient.sharedInstance.firstName)", message: "Your location is need, please enter it 😉")
        } else {
            self.startActivityAnimation(message: "Decoding location")
            let locationString = locationStringTextArea.text
            
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
        if personalLinkTextArea.text == personalLinkPlaceholder || personalLinkTextArea.text.isEmpty {
            self.showWarning(title: "Hey, \(APIClient.sharedInstance.firstName)", message: "Your fellow students would like to know about you, enter a personal link please! ☺️")
        } else if !verifyUrl(personalLinkTextArea.text) {
            self.showWarning(title: "That link seems wrong 😕", message: "Please enter a valid one ☺️")
        } else {
            self.startActivityAnimation(message: "Sending location")
            if let coordinates = studentCoordinates {
                var studentDict : [String : AnyObject] = [
                    APIClient.StudentLocationKey.lastName : APIClient.sharedInstance.lastName,
                    APIClient.StudentLocationKey.firstName : APIClient.sharedInstance.firstName,
                    APIClient.StudentLocationKey.uniqueKey : APIClient.sharedInstance.userID!,
                    APIClient.StudentLocationKey.mapString : locationStringTextArea.text!,
                    APIClient.StudentLocationKey.mediaURL : personalLinkTextArea.text!,
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
        self.question1Label.hidden = true
        self.question2Label.hidden = true
        self.question3Label.hidden = true
        self.locationStringTextArea.hidden = true
        self.findMapButton.hidden = true
        
        // All UI elements that need to be hidden
        self.personalLinkTextArea.hidden = false
        self.map.hidden = false
        self.submitButton.hidden = false
    }
    
    func configureUI() {
        let blueColor = UIColor(red: 0.250, green: 0.450, blue: 0.660, alpha: 1.0)
        let whiteColor = UIColor.whiteColor()
        let grayColor = UIColor(red: 0.850, green: 0.850, blue: 0.850, alpha: 1.0)
    
    
        lowerContainer.backgroundColor = grayColor
        upperContainer.backgroundColor = grayColor
        
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
        locationStringTextArea.backgroundColor = blueColor
        locationStringTextArea.textColor = whiteColor
        locationStringTextArea.font = UIFont(name: "Roboto-Medium", size: 18.0)
        locationStringTextArea.tintColor = whiteColor
        
        personalLinkTextArea.backgroundColor = blueColor
        personalLinkTextArea.textColor = whiteColor
        personalLinkTextArea.font = UIFont(name: "Roboto-Medium", size: 18.0)
        personalLinkTextArea.tintColor = whiteColor
        
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
    
    // MARK: Conforming to UITextViewDelegate and custom placeholder functionality
    // Based on this post: https://grokswift.com/uitextview-placeholder/
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        if textView.text == personalLinkPlaceholder || textView.text == locationStringPlaceholder {
            moveCursorToStart(textView)
        }
        return true
    }

    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let newLength = count("textView.text".utf16) + count(text.utf16) - range.length
        if newLength > 0 {
            if textView.text == personalLinkPlaceholder || textView.text == locationStringPlaceholder {
                if count(text.utf16) == 0 {
                    return false
                }
                applyNonPlaceholderStyle(textView)
                textView.text = ""
            }
            return true
        } else {
            if textView == personalLinkTextArea {
                applyPlaceholderStyle(textView, placeholderText: personalLinkPlaceholder)
            } else {
                applyPlaceholderStyle(textView, placeholderText: locationStringPlaceholder)
            }
            moveCursorToStart(textView)
            return false
        }
    }
    
    func applyPlaceholderStyle(textView: UITextView, placeholderText: String) {
        textView.textColor = UIColor.lightGrayColor()
        textView.text = placeholderText
    }
    
    func applyNonPlaceholderStyle(textView: UITextView) {
        textView.textColor = UIColor.whiteColor()
        textView.alpha = 1.0
    }
    
    func moveCursorToStart(textView: UITextView) {
        dispatch_async(dispatch_get_main_queue(), {
            textView.selectedRange = NSMakeRange(0, 0);
        })
    }
    
    
    
}
