//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Victor Guerra on 03/06/15.
//  Copyright (c) 2015 Victor Guerra. All rights reserved.
//

import Foundation
import MapKit

// Structure that represents an Student Location

struct StudentLocation : CustomStringConvertible {
    // Parse autogenerated id
    let objectId : String?
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
        let desc : [String: AnyObject] = [
            APIClient.StudentLocationKey.objectId : objectId!,
            APIClient.StudentLocationKey.lastName : lastName,
            APIClient.StudentLocationKey.firstName : firstName,
            APIClient.StudentLocationKey.uniqueKey : uniqueKey,
            APIClient.StudentLocationKey.mapString : mapString,
            APIClient.StudentLocationKey.mediaURL : mediaURL,
            APIClient.StudentLocationKey.latitude : latitude,
            APIClient.StudentLocationKey.longitude : longitude
        ]
        return desc.description
    }
    
    // Initialization from a dictionary
    init (dict : [String : AnyObject]) {
        objectId = dict[APIClient.StudentLocationKey.objectId] as? String
        lastName = dict[APIClient.StudentLocationKey.lastName] as! String
        firstName = dict[APIClient.StudentLocationKey.firstName] as! String
        uniqueKey = dict[APIClient.StudentLocationKey.uniqueKey] as! String
        mapString = dict[APIClient.StudentLocationKey.mapString] as! String
        mediaURL = dict[APIClient.StudentLocationKey.mediaURL] as! String
        latitude = dict[APIClient.StudentLocationKey.latitude] as! Float
        longitude = dict[APIClient.StudentLocationKey.longitude] as! Float
        
        // For the time being we just fill in this dates with the
        // current date
        createdAt = NSDate()
        updatedAt = NSDate()
    }
    
    // Helper function that for creating an array of StudentLocations out of an array of dicts.
    static func arrayFromDictionaries(results: [[String:AnyObject]]) -> [StudentLocation] {
        var locations = [StudentLocation]()
        for result in results {
            locations.append(StudentLocation(dict: result))
        }
        return locations
    }
}

// In order to use StudentLocation object almost as a MKAnnotation
extension StudentLocation {
    var title : String {
        return "\(firstName) \(lastName)"
    }
    
    var subtitle : String {
        return mediaURL
    }
    
    var coordinate : CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude) ,
            longitude: CLLocationDegrees(longitude))
    }
}

