//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Victor Guerra on 09/05/15.
//  Copyright (c) 2015 Victor Guerra. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginViewController : SLViewController, FBSDKLoginButtonDelegate, UITextFieldDelegate {

    // MARK: IB Outlets
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    @IBOutlet weak var loginButton: BorderedButton!
    
    @IBOutlet weak var loginUdacityLabel: UILabel!
    @IBOutlet weak var noAccountLabel: UILabel!
    @IBOutlet weak var loginErrorLabel: UILabel!
    @IBOutlet weak var signUpLabel: UIButton!
    
    
    @IBOutlet weak var logoContainer: UIView!
    @IBOutlet weak var udacityLoginContainer: UIView!
    @IBOutlet weak var facebookLoginContainer: UIView!
    @IBOutlet weak var errorContainer: UIView!
    
    // MARK: View Controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        fbLoginButton.delegate = self
        configureUI()
        
        emailText.delegate = self
        passwordText.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        passwordText.text = ""
        
        // If we have a FB Token we log in with it
        if let fbToken = FBSDKAccessToken.currentAccessToken()?.tokenString {
            fbLoginButton.hidden = true
            tryUdacityLoginWithFB(fbToken)
        } else {
            fbLoginButton.hidden = false
        }
        hideError()
    }
    
    // MARK: IB Actions
    @IBAction func showSignUpInBrowser() {
        let url = NSURL(string: APIClient.Constants.UdacitySignUpURL)!
        UIApplication.sharedApplication().openURL(url)
    }
    
    @IBAction func tryUdacityLogin(sender: AnyObject) {
        hideError()
        if !emailText.text.isEmail() {
            self.showWarning(title: "Invalid Email 😁",
                message: "Please verify the email address, it should be a valid one 😉!")
        }
        else if passwordText.text.isEmpty {
            self.showWarning(title: "No password 😔",
                message: "A password is needed for the log in 😏, please provide one")
        } else {
            let networkErrorClosure : onErrorClosure = { error in
                self.stopActivityAnimation()
                self.showError(message: "Oh no! Network Error: \(error!.localizedDescription)")
            }
            
            let loginErrorClosure : onErrorClosure = { error in
                self.stopActivityAnimation()
                self.showError(message: "Oh no! Log in failed: \(error!.localizedDescription)")
            }
            
            let successClosure : CompletionClosure = { result, error in
                self.stopActivityAnimation()
                self.showTabController()
            }
            
            self.startActivityAnimation(message: "Logging in ")
            APIClient.sharedInstance.logInToUdacityWithEmail(emailText.text, password: passwordText.text, networkErrorHandler: networkErrorClosure, responseErrorHandler: loginErrorClosure, completionHandler: successClosure)
            
        }
    }
    
    func tryUdacityLoginWithFB(fbToken: String!) {
        hideError()
        self.startActivityAnimation(message: "Loging in")
        APIClient.sharedInstance.logInToUdacityWithFBToken(fbToken) {result, error in
            self.stopActivityAnimation()
            if let errorMsg = error {
                self.showWarning(title: "Ups! Logging in didn't work! 😕",
                    message: errorMsg.localizedDescription)
            } else {
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
            self.showWarning(title: "Facebook Authentication did not work 😓", message: errorMsg.localizedDescription)
        } else if result.isCancelled {
            self.showWarning(title: "Something went wrong with Facebook Authentication 😞", message: "Please verify that your Udacity account is connected to your Facebook account and that you grant Udacity permission to access it.")
        } else {
            self.fbLoginButton.hidden = true
            tryUdacityLoginWithFB(result.token.tokenString)
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        // we handle logout differently
    }
    
    func hideError() {
        self.errorContainer.hidden = true
    }
    func showError(#message: String) {
        dispatch_async(dispatch_get_main_queue()) {
            self.errorContainer.hidden = false
            self.loginErrorLabel.text = message
            self.loginErrorLabel.sizeToFit()
        }
    }
    
    // MARK: UI Elements configuration
    func configureUI() {
        logoContainer.backgroundColor = UIColor.clearColor()
        udacityLoginContainer.backgroundColor = UIColor.clearColor()
        facebookLoginContainer.backgroundColor = UIColor.clearColor()
        errorContainer.backgroundColor = UIColor.clearColor()
        self.view.backgroundColor = UIColor.clearColor()

        // Nice gradient effect for background
        let colorTop = UIColor(red: 0.980, green: 0.580, blue: 0.040, alpha: 1.0).CGColor
        let colorBottom = UIColor(red: 0.980, green: 0.440, blue: 0.000, alpha: 1.0).CGColor
        var backgroundGradient = CAGradientLayer()
        backgroundGradient.colors = [colorTop, colorBottom]
        backgroundGradient.locations = [0.0, 1.0]
        backgroundGradient.frame = view.frame
        self.view.layer.insertSublayer(backgroundGradient, atIndex: 0)

        
        // All labels
        loginUdacityLabel.font = UIFont(name: "Roboto-Medium", size: 22.0)
        loginUdacityLabel.textColor = UIColor.whiteColor()
        noAccountLabel.font = UIFont(name: "Roboto-Medium", size: 18.0)
        noAccountLabel.textColor = UIColor.whiteColor()
        signUpLabel.titleLabel?.font = UIFont(name: "Roboto-Medium", size: 18.0)
        signUpLabel.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        loginErrorLabel.font = UIFont(name: "Roboto-Regular", size: 16.0)
        loginErrorLabel.textColor = UIColor.whiteColor()
        
        // Buttons
        let loginButtonColor = UIColor(red: 0.960, green: 0.330, blue: 0.0, alpha: 1.0)
        loginButton.titleLabel?.font = UIFont(name: "Roboto-Medium", size: 16.0)
        loginButton.backgroundColor = loginButtonColor
        loginButton.backingColor = loginButtonColor
        loginButton.highlightedBackingColor = loginButtonColor
        
        loginButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)

        fbLoginButton.titleLabel!.font = UIFont(name: "Roboto-Regular", size: 14.0)
    
        // Text Fields
        let textFieldBGColor = UIColor(red: 0.990, green: 0.780, blue: 0.580, alpha: 1.0)
        let emailTextFieldPaddingViewFrame = CGRectMake(0.0, 0.0, 13.0, 0.0);
        let emailTextFieldPaddingView = UIView(frame: emailTextFieldPaddingViewFrame)
        emailText.backgroundColor = textFieldBGColor
        emailText.textColor = UIColor.whiteColor()
        emailText.font = UIFont(name: "Roboto-Medium", size: 14.0)
        emailText.leftView = emailTextFieldPaddingView
        emailText.leftViewMode = .Always
        emailText.attributedPlaceholder = NSAttributedString(string: emailText.placeholder!, attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        emailText.tintColor = UIColor.whiteColor()

        let passwordTextFieldPaddingViewFrame = CGRectMake(0.0, 0.0, 13.0, 0.0);
        let passwordTextFieldPaddingView = UIView(frame: passwordTextFieldPaddingViewFrame)
        passwordText.backgroundColor = textFieldBGColor
        passwordText.textColor = UIColor.whiteColor()
        passwordText.font = UIFont(name: "Roboto-Medium", size: 14.0)
        passwordText.leftView = passwordTextFieldPaddingView
        passwordText.leftViewMode = .Always
        passwordText.attributedPlaceholder = NSAttributedString(string: passwordText.placeholder!, attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        passwordText.tintColor = UIColor.whiteColor()
    }
    
    // MARK: conforming to UITextField Delegate protocol
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
}


// for validating an email
// borrowed from: http://stackoverflow.com/questions/25471114/how-to-validate-an-e-mail-address-in-swift

extension String {
    func isEmail() -> Bool {
        let regex = NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .CaseInsensitive, error: nil)
        return regex?.firstMatchInString(self, options: nil, range: NSMakeRange(0, count(self))) != nil
    }
}
