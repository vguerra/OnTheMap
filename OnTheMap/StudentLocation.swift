//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Victor Guerra on 03/06/15.
//  Copyright (c) 2015 Victor Guerra. All rights reserved.
//

import Foundation

struct StudentLocation : Printable {
    // Parse autogenerated id
    let objectId : String
    // Udacity account user id
    let uniqueKey : String
    // first and last names
    let firstName : String
    let lastName : String
    // human-readable address 
    let mapString : String
    // URL provided by Student
    let mediaURL : String
    // geographic coordinates
    let latitude : Float
    let longitude : Float
    // creation and update dates
    let createdAt : NSDate
    let updatedAt : NSDate
    // conforming to Printable Protocol
    var description : String {
        return ""
    }
    
    init (dict : [String : AnyObject]) {
        objectId = dict["objectId"] as! String
        lastName = dict["lastName"] as! String
        firstName = dict["firstName"] as! String
        uniqueKey = dict["uniqueKey"] as! String
        mapString = dict["mapString"] as! String
        mediaURL = dict["mediaURL"] as! String
        latitude = dict["latitude"] as! Float
        longitude = dict["longitude"] as! Float
        
        let dateFormater = NSDateFormatter()
        dateFormater.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormater.timeStyle = NSDateFormatterStyle.MediumStyle
        
        createdAt = dateFormater.dateFromString(dict["createdAt"] as! String)!
        updatedAt = dateFormater.dateFromString(dict["updatedAt"] as! String)!
    }
    
    static func arrayFromDictionaries(results: [[String:AnyObject]]) -> [StudentLocation] {
        var locations = [StudentLocation]()
        
        for result in results {
            locations.append(StudentLocation(dict: result))
        }
        return locations
    }

}

