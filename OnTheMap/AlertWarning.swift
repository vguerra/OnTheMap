//
//  AlertWarning.swift
//  OnTheMap
//
//  Created by Victor Guerra on 14/07/15.
//  Copyright (c) 2015 Victor Guerra. All rights reserved.
//

import UIKit

// Extending all UIViewControolers to have a method
// that displays a nice UIAlertController
extension UIViewController {

    func showWarning(#title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let OKAction = UIAlertAction(title: "OK, Got it! 👍", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(OKAction)
        dispatch_async(dispatch_get_main_queue()) {
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
}
