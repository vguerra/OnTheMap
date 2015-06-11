//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Victor Guerra on 09/05/15.
//  Copyright (c) 2015 Victor Guerra. All rights reserved.
//

import UIKit

class LoginViewController : UIViewController {

    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    @IBAction func tryUdacityLogin(sender: AnyObject) {
        
        let jsonParameters : JSONDict = [
            APIClient.JSONBodyKeys.Credential : [
                APIClient.JSONBodyKeys.Username : emailText.text,
                APIClient.JSONBodyKeys.Password : passwordText.text
                ]
        ]
        
        println ("we are about to make the POST request")
        APIClient.sharedInstance().taskForPOSTMethod(APIClient.Constants.UdacityURLSecure,
            method: APIClient.Methods.AuthenticationSession, parameters: URLParametersDict(), headers: HeadersDict(),
            jsonBody: jsonParameters) { JSONBody, error in
            
            if let errorMsg = error {
                println ("got error: \(errorMsg)")
            } else {
                println("json: \(JSONBody)")
                println(JSONBody.valueForKey(APIClient.JSONResponseKeys.Session))
                APIClient.sharedInstance().udacity_account = JSONBody.valueForKey(APIClient.JSONResponseKeys.Account) as? JSONDict
                let user_id = APIClient.sharedInstance().udacity_account["key"] as! String
                
                let publicDataMethod = APIClient.subtituteKeyInMethod(APIClient.Methods.PublicUserData, key: "id", value: user_id)!
                println("\(publicDataMethod)")
                
                APIClient.sharedInstance().taskForGETMethod(APIClient.Constants.UdacityURLSecure, method: publicDataMethod,
                    parameters: URLParametersDict(), headers: HeadersDict() ) { JSONBody, error in
                        
                        if let errorMsg = error {
                            println("error fetching publi data: \(errorMsg)")
                        } else {
//                            println("publi data json: \(JSONBody)")
                            self.getStudentLocations()
                        }
                }
            }
        }
    }
    
    func getStudentLocations() -> Void {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let headers : HeadersDict = [
            "X-Parse-Application-Id" : appDelegate.parseAppId,
            "X-Parse-REST-API-Key": appDelegate.parseRESTAPIKey
        ]
        let parameters : URLParametersDict = [
            "limit" : 100
        ]
        APIClient.sharedInstance().taskForGETMethod(APIClient.Constants.ParseURLSecure, method: APIClient.Methods.StudentLocations, parameters: parameters, headers: headers) { JSONBody, error in
                if let errorMsg = error {
                    println("error fetching Students locations:\(errorMsg)")
                } else {
                    println("students location successful")
                    if let results = JSONBody.valueForKey("results") as? [[String : AnyObject]] {
                        println("results: \(results)")
                        let studenLocations = StudentLocation.arrayFromDictionaries(results)
                    } else {
                        println("unable to parse students location response")
                    }
                }
        }
    }
    
}
