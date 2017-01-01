//
//  PinEditorVC.swift
//  OnTheMap
//
//  Created by Donny Blaine on 12/21/16.
//  Copyright © 2016 RyStudios. All rights reserved.
//

import UIKit
import MapKit

class PinEditorVC: UIViewController, MKMapViewDelegate, UITextFieldDelegate  {


    @IBOutlet weak var questionLabel1: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    
    var studentUniqueId: String? = nil
    var method: String!
    var submittingLocation: Bool?
    var presetUserLocation: String?
    var userLocation : CLLocationCoordinate2D?
    var mapString = String()
    var gotLocation = false
    var sendingView: UIViewController?
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        submittingLocation = true
        locationTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        subscribedToKeyboardNotifications(true)
        if let presetLocation = presetUserLocation{
            locationTextField.text = presetLocation
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        subscribedToKeyboardNotifications(false)
    }
    
    //dismisses VC
    @IBAction func cancelPressed(_ sender: Any) {
       // self.dismiss(animated: true, completion: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    //Confirms location and details from user.
    @IBAction func confirmButtonPressed(_ sender: Any) {
        
        //If we havent gotten the location
        if gotLocation == false {
            getGeocodedLocationFromUser { (success, error) in
                if success{
                    self.locationTextField.text = "Enter a valid URL"
                    self.questionLabel1.text = "What are you"
                    self.submitButton.setTitle("Submit", for: UIControlState.normal)
                    self.gotLocation = true
                }else if let errormsg = error{
                    self.displayError(title: Constants.ErrorMessages.errorTitleGeocode, message: errormsg)
                }
            }
        }
        
        //If we have the location
        if gotLocation == true {
            self.activityIndicatoryShowing(showing: true, view: self.view)
            submitLocation(completionHandler: { (success, error) in
                DispatchQueue.main.async {
                    if success{
                        self.activityIndicatoryShowing(showing: false, view: self.view)
                        self.dismiss(animated: true, completion: {
                            if self.method == Constants.HTTPMethods.post {
                                self.sendingView?.displayError(title: "Success!", message: "Successfully created")
                            }else{
                            self.sendingView?.displayError(title: "Success!", message: "Successfully edited")
                            }
                        })
                    }else{
                        if let error = error{
                            self.activityIndicatoryShowing(showing: false, view: self.view)
                            self.displayError(title: Constants.ErrorMessages.errorTitleGeocode, message: error)
                        }
                    }
                }
            })
        }
    }
    
    func getGeocodedLocationFromUser(completionHandler: @escaping (_ success : Bool, _ error: String?) -> Void) {
        if let locationText = locationTextField.text, locationText != "" {
            mapString = locationText
            self.activityIndicatoryShowing(showing: true, view: self.view)
            CLGeocoder().geocodeAddressString(locationText, completionHandler: { (placemark, error) in
                self.processGeocodeResponse(withPlacemarks: placemark, error: error, coordCompletionHandler: { (success, error) in
                    guard error == nil else{
                        self.activityIndicatoryShowing(showing: false, view: self.view)
                        completionHandler(false, "Enter valid location")
                        return
                    }
                    
                    guard let userLocation = self.userLocation else{
                        self.activityIndicatoryShowing(showing: false, view: self.view)
                        completionHandler(false, "Enter valid location")
                        return
                    }
                    
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = userLocation
                    self.mapView.addAnnotation(annotation)
                    let span = MKCoordinateSpanMake(0.015, 0.015)
                    let region = MKCoordinateRegionMake(userLocation, span)
                    self.mapView.setRegion(region, animated: true)
                    completionHandler(true, nil)
                    self.activityIndicatoryShowing(showing: false, view: self.view)
                })
            })
        }else{
            completionHandler(false, "Textfield Empty")
        }
    }
    
    func submitLocation(completionHandler : @escaping (_ success: Bool, _ error : String?) -> Void){
        if let studyTopic = self.locationTextField.text, studyTopic != "", studyTopic != "Enter a valid URL", checkValidUrl(urlString: studyTopic) == true {
            UdacityClient.sharedInstance().getSingleUserData(userId: UdacityClient.sharedInstance().accountKey, completionHandler: { (firstName, lastName, error) in
                if let firstName = firstName, let lastName = lastName {
                    let student = StudentInformation(firstName: firstName, lastName: lastName, mediaURL: studyTopic , mapString: self.mapString, uniqueKey: UdacityClient.sharedInstance().accountKey, latitude: (self.userLocation?.latitude)!, longitude: (self.userLocation?.longitude)!)
                    
                    ParseClient.sharedInstance().putOrPostStudentLocation(student: student, httpMethod: self.method, objectId: self.studentUniqueId, completionHandler: { (success, error) in
                        if success{
                            StudentInformationModel.sharedInstance().downloadDataAndParse(completionHandler: { (success, error) in
                                if success{
                                    completionHandler(true, nil)
                                }else{
                                    completionHandler(false, "Error updating information")
                                }
                            })
                        }else{
                            completionHandler(false, "Error posting student information")
                        }
                    })
                }else{
                    print("Handle error \(error!)")
                    completionHandler(false, "Check network condition")
                }
            })
        }else{
            completionHandler(false, "Enter a valid URL")
        }
    }
    
    func processGeocodeResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?, coordCompletionHandler: (_ success: Bool, _ error: String?) -> Void) {
        guard error == nil else {
            coordCompletionHandler(false, "Could not find location")
            return
        }
        
        var location: CLLocation?
    
        if let placemarks = placemarks, placemarks.count > 0 {
            location = placemarks.first?.location
        }
        
        if let location = location {
            userLocation = location.coordinate
            coordCompletionHandler(true, nil)
            
        } else {
            coordCompletionHandler(false, "No matching location found")
        }
    }
    
    func keyboardWillShow(_ notification: Notification) {
        if UIDeviceOrientationIsLandscape(UIDevice.current.orientation) {
            view.frame.origin.y = (getKeyboardHeight(notification: notification) - (view.frame.height - locationTextField.frame.maxY) ) * -0.6
        }
        
    }
    func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    
    
    func subscribedToKeyboardNotifications(_ state: Bool) {
        if state {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)) , name: .UIKeyboardWillHide, object: nil)
        } else {
            NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
            NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.clearsOnBeginEditing = true
    }
    
    func checkValidUrl(urlString: String) -> Bool {
        if let url = URL(string: urlString){
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }
    
}
