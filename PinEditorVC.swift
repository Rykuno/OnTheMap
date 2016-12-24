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

    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func confirmButtonPressed(_ sender: Any) {
        print(studentUniqueId!)
        print(method)
        print(UdacityClient.sharedInstance().accountKey)
        if gotLocation == false {
        getGeocodedLocationFromUser { (success, error) in
            if success{
                    print("Button success")
                    self.locationTextField.text = ""
                    self.questionLabel1.text = "What are you"
                    self.submitButton.setTitle("Submit", for: UIControlState.normal)
                    self.gotLocation = true
                
            }
        }
            
        }
        if gotLocation == true {
            if let studyTopic = self.locationTextField.text {
                UdacityClient.sharedInstance().getSingleUserData(userId: UdacityClient.sharedInstance().accountKey, completionHandler: { (firstName, lastName, error) in
                    print("test")
                    if let firstName = firstName, let lastName = lastName{
                    let student = StudentInformation(firstName: firstName, lastName: lastName, mediaURL: studyTopic , mapString: self.mapString, uniqueKey: UdacityClient.sharedInstance().accountKey, latitude: (self.userLocation?.latitude)!, longitude: (self.userLocation?.longitude)!)
                    
                    ParseClient.sharedInstance().putOrPostStudentLocation(student: student, httpMethod: self.method, objectId: self.studentUniqueId, completionHandler: { (success, error) in
                        guard error == nil else{
                            self.displayError(title: "Oh-No!", message: error!)
                            return
                        }
                         
                        self.displayError(title: "Yay", message: "Successfully created Pin!")
                        self.dismiss(animated: true, completion: nil)
                    })
                    }
                })
            }
        }
        
        
        
    }
    
    func getGeocodedLocationFromUser(completionHandler: @escaping (_ success : Bool, _ error: String?) -> Void) {
        if let locationText = locationTextField.text{
            mapString = locationText
            CLGeocoder().geocodeAddressString(locationText, completionHandler: { (placemark, error) in
                self.processGeocodeResponse(withPlacemarks: placemark, error: error, coordCompletionHandler: { (success, error) in
                    guard error == nil else{
                        self.displayError(title: "Geocode 1", message: error!)
                        completionHandler(false, "Geocode 2")
                        return
                    }
                    
                    guard let userLocation = self.userLocation else{
                        self.displayError(title: "Geocode 3", message: error!)
                        completionHandler(false, "Geocode 4")
                        return
                    }
                    
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = userLocation
                    self.mapView.addAnnotation(annotation)
                    let span = MKCoordinateSpanMake(0.025, 0.025)
                    let region = MKCoordinateRegionMake(userLocation, span)
                    self.mapView.setRegion(region, animated: true)
                    completionHandler(true, nil)
                })
            })
        }else{
            completionHandler(false, "TextFields Empty")
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
             print("\(userLocation?.latitude), \(userLocation?.longitude)")
             coordCompletionHandler(true, nil)
            
        } else {
            print("No Matching Location Found")
            coordCompletionHandler(false, "No matching location found")
        }
        
    }
    
}
