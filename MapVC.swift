//
//  MapVC.swift
//  OnTheMap
//
//  Created by Donny Blaine on 12/19/16.
//  Copyright © 2016 RyStudios. All rights reserved.
//

import UIKit
import MapKit

class MapVC: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMapViewAndAnnotations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.addAnnotations(StudentInformationModel.sharedInstance().getStudentAnnotations())
    }
    
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        self.dismiss(animated: true) {
            UdacityClient.sharedInstance().deleteSession(completionHandler: { (success, error) in
                DispatchQueue.main.async {
                    if success{
                        print("Success Logging out")
                    }else if let error = error{
                        self.displayError(title: "Uh-Oh!", message: error)
                    }
                }
            })
        }
    }
    
    @IBAction func refreshButtonPressed(_ sender: Any) {
        mapView.removeAnnotations(self.mapView.annotations)
        loadMapViewAndAnnotations()
    }
    
    
    @IBAction func createPin(_ sender: Any) {
        let arrayOfStudents = StudentInformationModel.sharedInstance().getStudentInformation()
        let userObjectID = UdacityClient.sharedInstance().accountKey
        var userPresetLocation = String()
        var studentExists = false
        var studentObjectId = String()
        
        for student in arrayOfStudents {
            if student.uniqueKey == userObjectID {
                studentExists = true
                if let objectId = student.objectId, let userLocation = student.mapString {
                    userPresetLocation = userLocation
                    studentObjectId = objectId
                }
            }
        }
        
        if studentExists{
            let alert = UIAlertController(title: "Pin already exists", message: "Do you want to update information?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { (action: UIAlertAction!) in
                let controller = self.storyboard!.instantiateViewController(withIdentifier: "PinEditorVC") as! PinEditorVC
                controller.presetUserLocation = userPresetLocation
                controller.studentUniqueId = studentObjectId
                controller.method = Constants.HTTPMethods.put
                self.present(controller, animated: true, completion: nil)
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            }))
            
            present(alert, animated: true, completion: nil)
            
        }else{
            let controller = storyboard?.instantiateViewController(withIdentifier: "PinEditorVC") as! PinEditorVC
            controller.studentUniqueId = userObjectID
            controller.method = Constants.HTTPMethods.post
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    
    func loadMapViewAndAnnotations(){
        activityIndicatoryShowing(showing: true, view: self.view)
        StudentInformationModel.sharedInstance().downloadDataAndParse { (success, error) in
            DispatchQueue.main.async {
                if success{
                    self.activityIndicatoryShowing(showing: false, view: self.view)
                    self.mapView.addAnnotations(StudentInformationModel.sharedInstance().getStudentAnnotations())
                }else if let error = error {
                    self.displayError(title: "Oh-No!", message: error)
                    self.activityIndicatoryShowing(showing: false, view: self.view)
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
          
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let toOpen = view.annotation?.subtitle! {
                self.openUrlInBrowser(url: toOpen)
            }
        }
    }
}
