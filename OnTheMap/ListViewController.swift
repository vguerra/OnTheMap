//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Victor Guerra on 16/06/15.
//  Copyright (c) 2015 Victor Guerra. All rights reserved.
//

import UIKit

class ListViewController : SLViewController, UITableViewDataSource, UITableViewDelegate, CommonNavigationBar {
    

    @IBOutlet weak var locationsTable: UITableView!
    
    // MARK: ViewController life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addNavigationBar(self)
        self.navigationItem.title = "On The Map"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if APIClient.sharedInstance.studentLocations == nil {
            self.refresh()
        } else {
            self.locationsTable.reloadData()
        }
    }
    
    // MARK: Conforming to UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = APIClient.sharedInstance.studentLocations?.count {
            return count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let studentCell = tableView.dequeueReusableCellWithIdentifier("StudentLocationCell", forIndexPath: indexPath) 
        
        let location = APIClient.sharedInstance.studentLocations![indexPath.row]
        studentCell.imageView!.image = UIImage(named: "PinIcon")
        studentCell.textLabel!.text = String("\(location.firstName) \(location.lastName)")
        
        return studentCell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let studentLocation = APIClient.sharedInstance.studentLocations![indexPath.row]
        openMediaURL(studentLocation.mediaURL)
    }
    
    // MARK: conforming to CommonNavigationBar protocol
    func refresh() {
        self.refreshLocationsWihtHandler() {
            self.locationsTable.reloadData()
        }
    }
    
    func showInfoPostingView () {
        self.locationOverwrite()
    }

    func logOut() {
        logOutApp()
    }
}
