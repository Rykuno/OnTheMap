//
//  StudentInformationArray.swift
//  OnTheMap
//
//  Created by Donny Blaine on 12/19/16.
//  Copyright © 2016 RyStudios. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class StudentInformationModel {
    private var arrayOfStudentInformation = [StudentInformation]()
    private var arrayOfStudentAnnotations = [MKPointAnnotation]()
    private var objectId = String()
    
    //private constructor
    private init() {}
    
    
    //downloads and parses data for the student information/annotation arrays.
    func downloadDataAndParse(completionHandler: @escaping (_ success: Bool, _ error : String?) -> Void){
        ParseClient.sharedInstance().getAllStudentLocations { (locations, error) in
            guard error == nil else{
                completionHandler(false, "error occured")
                return
            }
            
            guard let locations = locations else{
                completionHandler(false, "error getting locations")
                return
            }
            
            self.arrayOfStudentInformation = StudentInformation.parseResultsFromDownload(locations: locations)
            self.arrayOfStudentAnnotations = StudentInformation.createAnnotationsFrom(studentInformationArray: self.arrayOfStudentInformation)
            completionHandler(true, nil)
        }
    }
    
    //returns array of StudentInformation
    func getStudentInformation() -> [StudentInformation]{
        return arrayOfStudentInformation
    }
    
    //returns array of StudentAnnotations
    func getStudentAnnotations() -> [MKPointAnnotation]{
        return arrayOfStudentAnnotations
    }
    
    //Singleton
    class func sharedInstance() -> StudentInformationModel{
        struct Singleton{
            static var sharedInstance = StudentInformationModel()
        }
        return Singleton.sharedInstance
    }
}

