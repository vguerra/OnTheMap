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

    var appDelegate : AppDelegate!
    
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    
    // MARK: View Controller life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        fbLoginButton.delegate = self
        
        
        FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onTokenUpdated:", name: FBSDKAccessTokenDidChangeNotification, object: nil)
        
    }
    
    func onTokenUpdated(notification: NSNotification) {
        if ( FBSDKAccessToken.currentAccessToken() != nil) {
            println("we got a token")
        } else {
            println("we lost it")
        }
    }
    
    @IBAction func showSignUpInBrowser() {
        let urlString = "https://www.udacity.com/account/auth#!/signin"
        let url = NSURL(string: urlString)!
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
                             println("publi data json: \(JSONBody)")
//                             perform segue
//                             self.getStudentLocations()
                            dispatch_async(dispatch_get_main_queue()) {
                                let tabBarController = self.storyboard!.instantiateViewControllerWithIdentifier("StudentsTabBarController") as! UITabBarController
                                self.presentViewController(tabBarController, animated: true, completion: nil)
                            }
                        }
                }
            }
        }
    }
    
    // MARK: conforming to FBSDKLoginButtonDelegate protocol
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
    
        if let errorMsg = error {
            println("fb loging error: \(errorMsg)")
        } else if result.isCancelled {
            println("access token: \(FBSDKAccessToken.currentAccessToken())")
            println("access token: \(FBSDKAccessToken.currentAccessToken().tokenString)")
            println("fb was cancelled by the user")
            println("fb authorization token: \(result.token!)")
        } else {
            println("fb authorization token: \(result.token!)")
            appDelegate.fbToken = result.token
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        println("loging out of FB")
    }
}
