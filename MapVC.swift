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
