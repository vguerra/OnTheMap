//
//  APIConstants.swift
//  OnTheMap
//
//  Created by Victor Guerra on 15/05/15.
//  Copyright (c) 2015 Victor Guerra. All rights reserved.
//

extension APIClient {

    struct StudentLocationKey {
        static let uniqueKey : String = "uniqueKey"
        static let firstName : String = "firstName"
        static let lastName : String = "lastName"
        static let mapString : String = "mapString"
        static let mediaURL : String = "mediaURL"
        static let latitude : String = "latitude"
        static let longitude : String = "longitude"
        static let objectId : String = "objectId"
    }
    
    struct Constants {
        static let UdacityURLSecure = "https://www.udacity.com/"
        static let ParseURLSecure = "https://api.parse.com/1/"
        static let UdacitySignUpURL = "https://www.udacity.com/account/auth#!/signin"
        static let skipConfig : [String : Int] = [
            UdacityURLSecure : 5,
            ParseURLSecure : 0
        ]
        static let parseAppId : String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let parseRESTAPIKey : String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let defaultLocationsCount : Int = 100
        static let OrderByField : String = "-updatedAt"
        static let ErrorDomain : String = "Udacity API"

    }
    
    struct Methods {
        static let AuthenticationSession = "api/session"
        static let PublicUserData = "api/users/{id}"
        static let StudentLocations = "classes/StudentLocation"
        static let StudentLocationId = "classes/StudentLocation/{id}"
    }
    
    struct ParameterKeys {
        static let limitKey = "limit"
        static let orderKey = "order"
    }
    
    struct HeaderKeys {
        static let ParseAppIdKey = "X-Parse-Application-Id"
        static let ParseAPIKey = "X-Parse-REST-API-Key"
        static let CookieTokenKey = "X-XSRF-Token"
        static let BaseHeaders : HeadersDict = [
            ParseAppIdKey : Constants.parseAppId,
            ParseAPIKey : Constants.parseRESTAPIKey
        ]
    }
    
    struct JSONBodyKeys {
        static let Credential = "udacity"
        static let Username = "username"
        static let Password = "password"
        static let FBCredential = "facebook_mobile"
        static let FBToken = "access_token"
    }
    
    struct JSONResponseKeys {
        static let Error = "error"
        static let Status = "status"
        static let Code = "code"
        static let Session = "session"
        static let Account = "account"
        static let AccountRegistered = "registered"
        static let AccountKey = "key"
        static let SessionID = "id"
        static let SessionExpiration = "expiration"
        static let Results = "results"
        static let ObjectId = "objectId"
        static let User = "user"
        static let LastName = "last_name"
        static let FirstName = "first_name"
    }
    
    struct Cookies {
        static let CookieTokenName = "UY-XSRF-TOKEN"
    }

}