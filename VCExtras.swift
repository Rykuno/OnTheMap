//
//  ViewControllerExtras.swift
//  OnTheMap
//
//  Created by Donny Blaine on 12/19/16.
//  Copyright © 2016 RyStudios. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController{
    
    func displayError(title: String, message: String){
            let alert = UIAlertController(title: "\(title)", message: "\(message)", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
    }
    
    // Show activity indicator
    func activityIndicatoryShowing(showing: Bool, view: UIView) {
        if showing {
            let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
            let container: UIView = UIView()
            let loadingView: UIView = UIView()
            container.tag = 1
            container.frame = view.frame
            container.center = view.center
            container.backgroundColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.3)
            loadingView.frame = CGRect(x:0, y:0, width:80, height:80)
            loadingView.center = view.center
            loadingView.backgroundColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.7)
            loadingView.clipsToBounds = true
            loadingView.layer.cornerRadius = 10
            activityIndicator.frame = CGRect(x:0, y:0, width:40, height:40)
            activityIndicator.center = CGPoint(x: (loadingView.frame.size.width / 2), y: (loadingView.frame.size.height / 2))
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
            activityIndicator.color = UIColor(red: 0.12, green: 0.78, blue: 0.91, alpha: 1.0)
            DispatchQueue.main.async {
                loadingView.addSubview(activityIndicator)
                container.addSubview(loadingView)
                //view.addSubview(loadingView)
                view.addSubview(container)
                activityIndicator.startAnimating()
            }
        } else {
            let subViews = view.subviews
            for subview in subViews{
                if subview.tag == 1 {
                    subview.removeFromSuperview()
                }
            }
        }
    }

    
    func openUrlInBrowser(url: String){
        if let url = URL(string:url){
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }else{
            self.displayError(title: "Oh-No", message: "Unable to open url")
        }
    }
}
