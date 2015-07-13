//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Victor Guerra on 09/05/15.
//  Copyright (c) 2015 Victor Guerra. All rights reserved.
//

import UIKit
//import FBSDKCoreKit
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
        if let fbToken = FBSDKAccessToken.currentAccessToken()?.tokenString {
            tryUdacityLoginWithFB(fbToken)
        }
    }
    
    // MARK: IB Actions
    @IBAction func showSignUpInBrowser() {
        let url = NSURL(string: APIClient.Constants.UdacitySignUpURL)!
        UIApplication.sharedApplication().openURL(url)
    }
    
    @IBAction func tryUdacityLogin(sender: AnyObject) {
        APIClient.sharedInstance().logInToUdacityWithEmail(emailText.text,
            password: passwordText.text) { result, error in
                if error == nil {
                    self.showTabController()
                }
        }
    }
    
    func tryUdacityLoginWithFB(fbToken: String!) {
        APIClient.sharedInstance().logInToUdacityWithFBToken(fbToken) {result, error in
            if error == nil {
                self.showTabController()
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
            tryUdacityLoginWithFB(result.token.tokenString)
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        println("loging out of FB")
    }
}
