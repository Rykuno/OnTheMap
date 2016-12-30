//
//  ViewController.swift
//  OnTheMap
//
//  Created by Donny Blaine on 12/17/16.
//  Copyright © 2016 RyStudios. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var accountSignupLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        accountSignupLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.accountSignup))
        accountSignupLabel.addGestureRecognizer(tap)
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
}

