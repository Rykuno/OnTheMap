//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by Donny Blaine on 12/19/16.
//  Copyright © 2016 RyStudios. All rights reserved.
//

import Foundation
import MapKit

struct StudentInformation{
    //Properties
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    var firstName: String
    var lastName: String
    var mediaURL: String
    var mapString: String?
    var uniqueKey: String
    var objectId: String?
    
    //Constructor for StudentInformation
    init(firstName: String, lastName: String, mediaURL: String, mapString: String, uniqueKey: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        self.firstName = firstName
        self.lastName = lastName
        self.mediaURL = mediaURL
        self.mapString = mapString
        self.uniqueKey = uniqueKey
        self.latitude = latitude
        self.longitude = longitude
    }
    
    //Constructor for StudentInformation from JSON dictionary
    init?(dictionary: [String:AnyObject]) {
        guard let latitude = dictionary[Constants.ParseConstants.ApiKeys.latitude] as? Double else {
            return nil
        }
        
        guard let longitude = dictionary[Constants.ParseConstants.ApiKeys.longitude] as? Double else {
            return nil
        }
        
        guard let firstName = dictionary[Constants.ParseConstants.ApiKeys.firstName] as? String else {
            return nil
        }
        
        guard let lastName = dictionary[Constants.ParseConstants.ApiKeys.lastName] as? String else {
            return nil
        }
        
        guard let mapString = dictionary[Constants.ParseConstants.ApiKeys.mapString] as? String else{
            return nil
        }
        
        guard let mediaURL = dictionary[Constants.ParseConstants.ApiKeys.mediaUrl] as? String else {
            return nil
        }
        
        guard let uniqueKey = dictionary[Constants.ParseConstants.ApiKeys.uniqueKey] as? String else {
            return nil
        }
        
        guard let objectId = dictionary[Constants.ParseConstants.ApiKeys.objectID] as? String else {
            return nil
        }
        
        self.latitude = CLLocationDegrees(latitude)
        self.longitude = CLLocationDegrees(longitude)
        self.firstName = firstName
        self.lastName = lastName
        self.mapString = mapString
        self.mediaURL = mediaURL
        self.uniqueKey = uniqueKey
        self.objectId = objectId
    }
    
    //creates an array of Students from the JSON array passed in.
    static func parseResultsFromDownload(locations: [[String: AnyObject]]) -> [StudentInformation] {
        var arrayOfStudents = [StudentInformation]()
        var errorCount = 0
        
        for location in locations {
            if let student = StudentInformation(dictionary: location){
                arrayOfStudents.append(student)
            }else{
                errorCount += 1
            }
        }
        print("error parsing \(errorCount) students")
        return arrayOfStudents
    }
    
    //creates an array of map annotations from the student array
    static func createAnnotationsFrom(studentInformationArray: [StudentInformation])-> [MKPointAnnotation]{
        var arrayOfAnnonations = [MKPointAnnotation]()
        
        for student in studentInformationArray{
            let coordinate = CLLocationCoordinate2D(latitude: student.latitude, longitude: student.longitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(student.firstName) \(student.lastName)"
            annotation.subtitle = student.mediaURL
            arrayOfAnnonations.append(annotation)
        }
        return arrayOfAnnonations
    }
}
