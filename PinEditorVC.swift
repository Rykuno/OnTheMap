//
//  PinEditorVC.swift
//  OnTheMap
//
//  Created by Donny Blaine on 12/21/16.
//  Copyright © 2016 RyStudios. All rights reserved.
//

import UIKit
import MapKit

class PinEditorVC: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var questionLabel1: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    
    var studentUniqueId: String? = nil
    var method: String!
    var submittingLocation: Bool?
    var presetUserLocation: String?
    var userLocation : CLLocationCoordinate2D?
    var mapString = String()
    var gotLocation = false
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        submittingLocation = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if let presetLocation = presetUserLocation{
            locationTextField.text = presetLocation
        }
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func confirmButtonPressed(_ sender: Any) {
        if gotLocation == false {
            getGeocodedLocationFromUser { (success, error) in
                if success{
                    self.locationTextField.text = ""
                    self.questionLabel1.text = "What are you"
                    self.submitButton.setTitle("Submit", for: UIControlState.normal)
                    self.gotLocation = true
                }else if let errormsg = error{
                    self.displayError(title: "Geocode Error", message: errormsg)
                }
            }
        }
        
        if gotLocation == true {
            self.activityIndicatoryShowing(showing: true, view: self.view)
            submitLocation(completionHandler: { (success, error) in
                DispatchQueue.main.async {
                    if success{
                        self.activityIndicatoryShowing(showing: false, view: self.view)
                        self.dismiss(animated: true, completion: nil)
                    }else{
                        if let error = error{
                            self.activityIndicatoryShowing(showing: false, view: self.view)
                            self.displayError(title: "Geocode Error", message: error)
                        }
                    }
                }
            })
        }
    }
    
    func getGeocodedLocationFromUser(completionHandler: @escaping (_ success : Bool, _ error: String?) -> Void) {
        if let locationText = locationTextField.text, locationText != "" {
            mapString = locationText
            CLGeocoder().geocodeAddressString(locationText, completionHandler: { (placemark, error) in
                self.processGeocodeResponse(withPlacemarks: placemark, error: error, coordCompletionHandler: { (success, error) in
                    guard error == nil else{
                        completionHandler(false, "Enter valid location")
                        return
                    }
                    
                    guard let userLocation = self.userLocation else{
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
                })
            })
        }else{
            completionHandler(false, "Textfield Empty")
        }
    }
    
    func submitLocation(completionHandler : @escaping (_ success: Bool, _ error : String?) -> Void){
        if let studyTopic = self.locationTextField.text, studyTopic != "" {
            UdacityClient.sharedInstance().getSingleUserData(userId: UdacityClient.sharedInstance().accountKey, completionHandler: { (firstName, lastName, error) in
                if let firstName = firstName, let lastName = lastName{
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
                    completionHandler(false, "Failed to parse data")
                }
            })
        }else{
            completionHandler(false, "Enter what you're studying")
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
    
}
