//
//  ViewController.swift
//  OnTheMap
//
//  Created by Donny Blaine on 12/17/16.
//  Copyright © 2016 RyStudios. All rights reserved.
//

import UIKit

class LoginVC: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var accountSignupLabel: UILabel!
    let textDelegate = TextFieldDelegate()
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginWithFacebookButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        accountSignupLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.accountSignup))
        accountSignupLabel.addGestureRecognizer(tap)
        emailTextField.delegate = textDelegate
        passwordTextField.delegate = textDelegate
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        subscribedToKeyboardNotifications(false) 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        subscribedToKeyboardNotifications(true)
    }
    
    
    func accountSignup(){
        self.openUrlInBrowser(url: Constants.UdacityConstants.UrlConstants.methodForSignUp)
    }
    
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        activityIndicatoryShowing(showing: true, view: self.view)
        if let emailText = emailTextField.text, let passwordText = passwordTextField.text{
            UdacityClient.sharedInstance().postLoginSession(email: emailText, password: passwordText) { (success, error) in
                DispatchQueue.main.async {
                    if success{
                        self.completeLoginProcedure {
                            self.activityIndicatoryShowing(showing: false, view: self.view)
                        }
                    }else if let error = error {
                        self.activityIndicatoryShowing(showing: false, view: self.view)
                        self.displayError(title: Constants.ErrorMessages.errorTitleGeneric, message: error)
                    }
                }
            }
        }
    }
    
    func completeLoginProcedure(completionHandler : @escaping ()->()){
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
        self.present(controller, animated: true) {
            completionHandler()
        }
    }
    
    
    // Move view up, so both textviews and loginButton are visible
    func keyboardWillShow(_ notification: Notification) {
        view.frame.origin.y = (getKeyboardHeight(notification: notification) - (view.frame.height - loginWithFacebookButton.frame.maxY) ) * -1
    }
    // Move view back
    func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    
    
    // Adding or removing observers for keyboard notifications
    func subscribedToKeyboardNotifications(_ state: Bool) {
        if state {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)) , name: .UIKeyboardWillHide, object: nil)
        } else {
            NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
            NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
        }
    }
    
    
}

