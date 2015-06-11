//
//  UDconstants.swift
//  OnTheMap
//
//  Created by Victor Guerra on 15/05/15.
//  Copyright (c) 2015 Victor Guerra. All rights reserved.
//

extension APIClient {

    struct Constants {
        static let UdacityURLSecure = "https://www.udacity.com/"
        static let ParseURLSecure = "https://api.parse.com/1/"
        static let api_key = "api_key"
        static let skipConfig : [String : Int] = [
            "https://www.udacity.com/" : 5,
            "https://api.parse.com/1/" : 0
        ]
    }
    
    struct Methods {
        static let AuthenticationSession = "api/session"
        static let PublicUserData = "api/users/{id}"
        static let StudentLocations = "classes/StudentLocation"
    }
    
    struct ParameterKeys {
    }
    
    struct JSONBodyKeys {
        static let Credential = "udacity"
        static let Username = "username"
        static let Password = "password"
    }
    
    struct JSONResponseKeys {
        static let StatusMessage = "status_message"
        static let Session = "session"
        static let Account = "account"
        static let AccountRegistered = "registered"
        static let AccountKey = "key"
        static let SessionID = "id"
        static let SessionExpiration = "expiration"
    }

}