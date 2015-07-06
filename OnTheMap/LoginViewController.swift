//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Victor Guerra on 09/05/15.
//  Copyright (c) 2015 Victor Guerra. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController : UIViewController, FBSDKLoginButtonDelegate {

    // MARK: IB Outlets
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    
    // MARK: View Controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        fbLoginButton.delegate = self
        println("view did load, do we have a FB token? \(FBSDKAccessToken.currentAccessToken() != nil)")
    }
    
    // MARK: IB Actions
    @IBAction func showSignUpInBrowser() {
        let url = NSURL(string: APIClient.Constants.UdacitySignUpURL)!
        UIApplication.sharedApplication().openURL(url)
    }
    
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
                self.appDelegate.userID = user_id
                
                let publicDataMethod = APIClient.subtituteKeyInMethod(APIClient.Methods.PublicUserData, key: "id", value: user_id)!
                println("\(publicDataMethod)")
                
                APIClient.sharedInstance().taskForGETMethod(APIClient.Constants.UdacityURLSecure, method: publicDataMethod,
                    parameters: URLParametersDict(), headers: HeadersDict() ) { JSONBody, error in
                        
                        if let errorMsg = error {
                            println("error fetching publi data: \(errorMsg)")
                        } else {
                            self.showTabController()
                        }
                }
            }
        }
    }
    
    func loginWithFB() {
        let jsonParameters : JSONDict = [
            APIClient.JSONBodyKeys.FBCredential : [
                APIClient.JSONBodyKeys.FBToken : appDelegate.fbToken!.tokenString
            ]
        ]
        
        APIClient.sharedInstance().taskForPOSTMethod(APIClient.Constants.UdacityURLSecure, method: APIClient.Methods.AuthenticationSession, parameters: URLParametersDict(), headers: HeadersDict(), jsonBody: jsonParameters) {
        
            result , error in
            
            if let errorMsg = error {
                println("error: \(errorMsg)")
            } else {
                println("result from post: \(result)")
            }
        
        }
    
    
    }
    
    func showTabController() {
        dispatch_async(dispatch_get_main_queue()) {
            let tabBarController = self.storyboard!.instantiateViewControllerWithIdentifier("StudentsTabBarController") as! UITabBarController
            self.presentViewController(tabBarController, animated: true, completion: nil)
            
        }
    }
    
    // MARK: conforming to FBSDKLoginButtonDelegate protocol
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
    
        if let errorMsg = error {
            println("fb loging error: \(errorMsg)")
        } else if result.isCancelled {
            println("fb was cancelled by the user")
        } else {
            println("access token: \(FBSDKAccessToken.currentAccessToken().tokenString)")
            appDelegate.fbToken = result.token
            loginWithFB()
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        println("loging out of FB")
    }
}
