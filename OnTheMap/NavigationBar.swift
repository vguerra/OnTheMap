//
//  NavigationBar.swift
//  OnTheMap
//
//  Created by Victor Guerra on 13/07/15.
//  Copyright (c) 2015 Victor Guerra. All rights reserved.
//

import UIKit

func addNavigationBar(view: UIViewController) {
    let logoutButton = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: view, action: "logOut")
    let refreshButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: view, action: "refresh")
    let locationButton = UIBarButtonItem(image: UIImage(named: "PinIcon"), style: UIBarButtonItemStyle.Plain, target: view, action: "showInfoPostingView")
    
    view.navigationItem.setLeftBarButtonItems([logoutButton], animated: true)
    view.navigationItem.setRightBarButtonItems([refreshButton, locationButton], animated: true)
}

// protocol 

protocol CommonNavigationBar {
    func logOut();
    func refresh();
    func showInfoPostingView();
}