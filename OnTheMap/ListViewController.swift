//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Victor Guerra on 16/06/15.
//  Copyright (c) 2015 Victor Guerra. All rights reserved.
//

import UIKit

class ListViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addNavigationBar(self)
        self.navigationItem.title = "On The Map"
    }
    
    func showInfoPostingView () {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("InfoPostingViewController") as! InfoPostingViewController
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    
    // MARK: Conforming to UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let studentCell = tableView.dequeueReusableCellWithIdentifier("StudentLocationCell", forIndexPath: indexPath) as! UITableViewCell
        
        studentCell.imageView!.image = UIImage(named: "PinIcon")
        studentCell.textLabel!.text = "Victor Guerra"
        
        return studentCell
    }
    
    func dummySelector() {
        println("dummy proc called")
    }

    func logOut() {
        APIClient.sharedInstance.logOutFromUdacity() { error in
            if error == nil {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }

}
