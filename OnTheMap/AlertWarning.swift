//
//  AlertWarning.swift
//  OnTheMap
//
//  Created by Victor Guerra on 14/07/15.
//  Copyright (c) 2015 Victor Guerra. All rights reserved.
//

import UIKit

extension UIViewController {

    func showWarning(message: String) {
        let alert = UIAlertController(title: "Warning!", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let OKAction = UIAlertAction(title: "OK!", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(OKAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
