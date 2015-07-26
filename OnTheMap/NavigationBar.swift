//
//  NavigationBar.swift
//  OnTheMap
//
//  Created by Victor Guerra on 13/07/15.
//  Copyright (c) 2015 Victor Guerra. All rights reserved.
//

import UIKit

// Protocol definition to which all ViewControllers conform to that want 
// to have the common NavigationBar

protocol CommonNavigationBar {
    func logOut();
    func refresh();
    func showInfoPostingView();
}

// Helper function that configures the common NavigationBar
func addNavigationBar(view: CommonNavigationBar) {
    let viewController = view as! UIViewController
    let logoutButton = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain,
        target: viewController, action: "logOut")
    let refreshButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh,
        target: viewController, action: "refresh")
    let locationButton = UIBarButtonItem(image: UIImage(named: "PinIcon"),
        style: UIBarButtonItemStyle.Plain, target: viewController, action: "showInfoPostingView")
    
    viewController.navigationItem.setLeftBarButtonItems([logoutButton], animated: true)
    viewController.navigationItem.setRightBarButtonItems([refreshButton, locationButton], animated: true)
}

