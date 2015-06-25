//
//  AppDelegate.swift
//  OnTheMap
//
//  Created by Victor Guerra on 21/04/15.
//  Copyright (c) 2015 Victor Guerra. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    // what is known as uniqueKey for the Parse API.
    var userID : String!
    var objectID : String?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        return true
    }

}

