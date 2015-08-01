//
//  SLViewController.swift
//  OnTheMap
//
//  Created by Victor Guerra on 26/07/15.
//  Copyright (c) 2015 Victor Guerra. All rights reserved.
//

import UIKit

// SLViewController implements basic functionality which is 
// commnly used among all ViewControllers in this application

class SLViewController : UIViewController {

    var activityIndicator : UIActivityIndicatorView! = nil
    var activityView : UIView! = nil
    var activityLabel : UILabel! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUIElements()
    }

    // MARK: Activity view life cycle
    func setUpUIElements() {
        let sideLength:CGFloat = 170.0
        activityView = UIView(frame: CGRectMake(self.view.bounds.width/2 - sideLength/2,
            self.view.bounds.height/2 - sideLength/2, sideLength, sideLength))
        activityView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        activityView.clipsToBounds = true;
        activityView.layer.cornerRadius = 10.0;
        activityView.hidden = true
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        activityIndicator.frame = CGRectMake(0, 0, activityView.bounds.size.width, activityView.bounds.size.height)
        activityIndicator.hidesWhenStopped = true
        
        
        
        activityLabel = UILabel(frame: CGRectMake(20, 115, 130, 22))
        activityLabel.font = UIFont(name: "Roboto-Medium", size: 16.0)
        activityLabel.backgroundColor = UIColor.clearColor()
        activityLabel.textColor = UIColor.whiteColor()
        activityLabel.adjustsFontSizeToFitWidth = true
        activityLabel.textAlignment = NSTextAlignment.Center
        
        activityView.addSubview(activityLabel)
        activityView.addSubview(activityIndicator)
        self.view.addSubview(activityView)
    }
    
    func startActivityAnimation(#message: String) {
        dispatch_async(dispatch_get_main_queue()) {
            self.activityLabel.text = message
            self.activityView.hidden = false
            self.activityIndicator.startAnimating()
        }
    }
    
    func stopActivityAnimation() {
        dispatch_async(dispatch_get_main_queue()) {
            self.activityIndicator.stopAnimating()
            self.activityView.hidden = true
        }
    }
    
    // Helper that fetches locations from the server and executes a hanlder
    // this code runs always on the background
    func refreshLocationsWihtHandler(handler: ()->Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            self.startActivityAnimation(message: "Loading locations")
            APIClient.sharedInstance.getStudentLocations() { locations, error in
                if let errorMsg = error {
                    self.stopActivityAnimation()
                    self.showWarning(title: "Attempt to fetch classmates locations failed 😢",
                        message: errorMsg.localizedDescription)
                } else {
                    handler()
                    self.stopActivityAnimation()
                }
            }
        }
    }
    
    // Helper that checks the need of overwriting student location on the server
    func locationOverwrite() {
        // check if we have already an ObjectId
        if APIClient.sharedInstance.objectID == nil {
            self.startActivityAnimation(message: "Checking for Location")
            APIClient.sharedInstance.queryStudentLocation([APIClient.StudentLocationKey.uniqueKey : APIClient.sharedInstance.userID]) {
                locations, error in
                self.stopActivityAnimation()
                if let errorMsg = error {
                    self.showWarning(title: "Upss! 😁", message: errorMsg.localizedDescription)
                } else if locations!.count > 0 {
                    let location = locations![0]
                    APIClient.sharedInstance.objectID = location.objectId
                    self.showOverwriteAlert()
                } else {
                    let controller = self.storyboard!.instantiateViewControllerWithIdentifier("InfoPostingViewController") as! InfoPostingViewController
                    dispatch_async(dispatch_get_main_queue()) {
                        self.presentViewController(controller, animated: true, completion: nil)
                    }
                }
            }
        } else {
            self.showOverwriteAlert()
        }
    }
    
    func showOverwriteAlert() {
        // check if we want to overwrite.
        let overwriteAlert = UIAlertController(title: "Did you know that ... ", message: "you have already submitted a location?, Would you like to overwrite it?", preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "No, I am good! 👌🏻", style: UIAlertActionStyle.Default, handler: nil)
        let overwriteAction = UIAlertAction(title: "Yes please! 👍", style: UIAlertActionStyle.Default) { action in
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("InfoPostingViewController") as! InfoPostingViewController
            
            self.presentViewController(controller, animated: true, completion: nil)
        }
        overwriteAlert.addAction(overwriteAction)
        overwriteAlert.addAction(okAction)
        dispatch_async(dispatch_get_main_queue()) {
            self.presentViewController(overwriteAlert, animated: true, completion: nil)
        }
    }
    
    // Logging out of the app
    func logOutApp() {
        self.startActivityAnimation(message: "Logging out")
        APIClient.sharedInstance.logOutFromUdacity() { error in
            self.stopActivityAnimation()
            if let errorMsg = error {
                self.showWarning(title: "It was not possible to log you out! 😑", message: errorMsg.localizedDescription)
            } else {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    // Helper that opens valid URLs
    func openMediaURL(mediaURL: String) {
        if let url = NSURL(string: mediaURL) {
            let app = UIApplication.sharedApplication()
            if !app.canOpenURL(url) {
                self.showWarning(title: "Oh NO! 😱", message: "The URL submitted by this user couldn't be opened.")
            } else {
                app.openURL(url)
            }
        } else {
            self.showWarning(title: "Oh NO! 😱", message: "The URL submitted by this user is not valid.")
        }
    }
}
