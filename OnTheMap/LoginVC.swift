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
        self.openUrlInBrowser(url: "https://www.udacity.com/account/auth#!/signup")
    }
    
    

    @IBAction func loginButtonPressed(_ sender: Any) {
        activityIndicatoryShowing(showing: true, view: self.view)
        UdacityClient.sharedInstance().postLoginSession(email: "rykuno@gmail.com", password: "all4gyrin") { (success, error) in
            DispatchQueue.main.async {
                if success{
                    self.completeLoginProcedure {
                        self.activityIndicatoryShowing(showing: false, view: self.view)
                    }
                }else if let error = error {
                    self.displayError(title: "Uh-Oh!", message: error)
                    self.activityIndicatoryShowing(showing: false, view: self.view)
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

