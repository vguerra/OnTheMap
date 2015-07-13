//
//  APIConvenience.swift
//  OnTheMap
//
//  Created by Victor Guerra on 07/07/15.
//  Copyright (c) 2015 Victor Guerra. All rights reserved.
//

import Foundation


// This extension encapsulates 

extension APIClient {
    
    func getStudentLocations( completionHandler : (locations : [StudentLocation]? , error:NSError?) -> Void ) -> Void {
        let headers : HeadersDict = HeaderKeys.BaseHeaders
        let parameters : URLParametersDict = [
            ParameterKeys.limitKey : Constants.defaultLocationsCount
        ]
        APIClient.sharedInstance.taskForGETMethod(Constants.ParseURLSecure, method: Methods.StudentLocations,
            parameters: parameters, headers: headers) { JSONBody, error in
            if let errorMsg = error {
                completionHandler(locations: nil, error: errorMsg)
            } else {
                if let results = JSONBody.valueForKey(JSONResponseKeys.Results) as? [[String : AnyObject]] {
                    completionHandler(locations: StudentLocation.arrayFromDictionaries(results), error: nil)
                } else {
                    println("unable to parse students location response")
                }
            }
        }
    }
    
    func queryStudentLocation(whereDict : [String : AnyObject],
        completionHandler : (locations : [StudentLocation]?, error : NSError?) -> Void) -> Void {
        
        let headers : HeadersDict = HeaderKeys.BaseHeaders
        
        // composing where url parameter value.
        var values = [String]()
        for (key, value) in whereDict {
            values.append("\"\(key)\":\"\(value)\"")
        }
        
        var parameters = URLParametersDict()
        if !values.isEmpty {
            let whereValues = ",".join(values)
            parameters["where"] = "{\(whereValues)}"
        }
        
        APIClient.sharedInstance.taskForGETMethod(APIClient.Constants.ParseURLSecure,
            method: APIClient.Methods.StudentLocations, parameters: parameters, headers: headers) { JSONBody, error in
            if let errorMsg = error {
                completionHandler(locations: nil, error: errorMsg)
            } else {
                if let results = JSONBody.valueForKey(JSONResponseKeys.Results) as? [[String : AnyObject]] {
                    completionHandler(locations: StudentLocation.arrayFromDictionaries(results), error: nil)
                } else {
                    println("Error querying student locations")
                    
                }
            }
        }
    }
    
    func postStudentLocation(studentLocation : StudentLocation,
        completionHandler : (objectId : String?, error : NSError?) -> Void) -> Void {
        
        let headers : HeadersDict = HeaderKeys.BaseHeaders
        
        let jsonBody : JSONDict = [
            StudentLocationKey.uniqueKey : studentLocation.uniqueKey,
            StudentLocationKey.firstName : studentLocation.firstName,
            StudentLocationKey.lastName  : studentLocation.lastName,
            StudentLocationKey.mapString : studentLocation.mapString,
            StudentLocationKey.mediaURL  : studentLocation.mediaURL,
            StudentLocationKey.latitude  : studentLocation.latitude,
            StudentLocationKey.longitude : studentLocation.longitude
        ]
        
        APIClient.sharedInstance.taskForPOSTMethod(APIClient.Constants.ParseURLSecure, method: APIClient.Methods.StudentLocations, parameters: URLParametersDict(), headers: headers, jsonBody: jsonBody) {
            JSONBody , error in
            if let errorMsg = error {
                completionHandler(objectId: nil, error: errorMsg)
            } else {
                completionHandler(objectId: (JSONBody.valueForKey(JSONResponseKeys.ObjectId) as! String), error: nil)
            }
        }
    }
    
    func putStudentLocation(studentLocation : StudentLocation, completionHandler : (error : NSError?) -> Void) -> Void {
        let headers : HeadersDict = HeaderKeys.BaseHeaders
        
        let jsonBody : JSONDict = [
            StudentLocationKey.uniqueKey : studentLocation.uniqueKey,
            StudentLocationKey.firstName : studentLocation.firstName,
            StudentLocationKey.lastName  : studentLocation.lastName,
            StudentLocationKey.mapString : studentLocation.mapString,
            StudentLocationKey.mediaURL  : studentLocation.mediaURL,
            StudentLocationKey.latitude  : studentLocation.latitude,
            StudentLocationKey.longitude : studentLocation.longitude
        ]
        
        let method = APIClient.subtituteKeyInMethod(APIClient.Methods.StudentLocationId,
            key: JSONResponseKeys.SessionID, value: studentLocation.objectId!)!
        
        APIClient.sharedInstance.taskForPUTMethod(APIClient.Constants.ParseURLSecure,
            method: method, headers: headers, jsonBody: jsonBody) { JSONBody, error in
            if let errorMsg = error {
                completionHandler(error: errorMsg)
            } else {
                completionHandler(error: nil)
            }
        }
    }
    
    // MARK: Login in and out of udacity.
    
    func logInToUdacityWithEmail(email : String, password : String, completionHandler: CompletionClosure) {
        let jsonParameters : JSONDict = [
            APIClient.JSONBodyKeys.Credential : [
                APIClient.JSONBodyKeys.Username : email,
                APIClient.JSONBodyKeys.Password : password
            ]
        ]
        
        APIClient.sharedInstance.taskForPOSTMethod(APIClient.Constants.UdacityURLSecure,
            method: APIClient.Methods.AuthenticationSession, parameters: URLParametersDict(), headers: HeadersDict(),
            jsonBody: jsonParameters) { JSONBody, error in
                
                if let errorMsg = error {
                    completionHandler(result: nil, error: errorMsg)
                } else {
                    APIClient.sharedInstance.udacity_account = JSONBody.valueForKey(APIClient.JSONResponseKeys.Account) as? JSONDict
                    let user_id = APIClient.sharedInstance.udacity_account["key"] as! String
                    APIClient.sharedInstance.userID = user_id
                    
                    let publicDataMethod = APIClient.subtituteKeyInMethod(APIClient.Methods.PublicUserData, key: "id", value: user_id)!
                    
                    APIClient.sharedInstance.taskForGETMethod(APIClient.Constants.UdacityURLSecure,
                        method: publicDataMethod, parameters: URLParametersDict(),
                        headers: HeadersDict()) { JSONBody, error in
                            if let errorMsg = error {
                                completionHandler(result: nil, error: errorMsg)
                            } else {
                                completionHandler(result: JSONBody, error: nil)
                            }
                    }
                }
        }
    }
    
    func logInToUdacityWithFBToken(fbToken: String!, completionHandler : CompletionClosure) {
        let jsonParameters : JSONDict = [
            APIClient.JSONBodyKeys.FBCredential : [
                APIClient.JSONBodyKeys.FBToken : fbToken
            ]
        ]
        
        APIClient.sharedInstance.taskForPOSTMethod(APIClient.Constants.UdacityURLSecure,
            method: APIClient.Methods.AuthenticationSession, parameters: URLParametersDict(),
            headers: HeadersDict(), jsonBody: jsonParameters) { result , error in
                if let errorMsg = error {
                    completionHandler(result: nil, error: errorMsg)
                } else {
                    APIClient.sharedInstance.fbToken = fbToken
                    completionHandler(result: result, error: nil)
                }
        }
    }
    
    func logOutFromUdacity(completionHandler : (error : NSError?) -> Void) -> Void {
        var headers = HeadersDict()
        
        var xsrfCookie : NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies as! [NSHTTPCookie] {
            if cookie.name == Cookies.CookieTokenName {
                headers[HeaderKeys.CookieTokenKey] = cookie.value!
            }
        }
        
        APIClient.sharedInstance.taskForDELETEMethod(APIClient.Constants.UdacityURLSecure,
            method: APIClient.Methods.AuthenticationSession, parameters: URLParametersDict(),
            headers: headers) {JSONBody, error in
            if let errorMsg = error {
                completionHandler(error: errorMsg)
            } else {
                completionHandler(error: nil)
            }
        }
    }



}