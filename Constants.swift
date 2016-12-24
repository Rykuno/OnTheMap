//
//  Constants.swift
//  OnTheMap
//
//  Created by Donny Blaine on 12/18/16.
//  Copyright © 2016 RyStudios. All rights reserved.
//

import Foundation

class Constants {
    struct UdacityConstants{
        
        struct UrlConstants{
            static let methodForPostingSession = "https://www.udacity.com/api/session"
            static let methodForGettingUserData = "https://www.udacity.com/api/users/"
        }
        
        struct ApiKeys{
            static let account = "account"
            static let key = "key"
            static let lastName = "last_name"
            static let firstName = "first_name"

        }
    }
    
    struct ParseConstants{
        struct UrlConstants{
            static let parseAppID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
            static let RESTAPIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
            static let methodForStudentLocationsWithParameters = "https://parse.udacity.com/parse/classes/StudentLocation?limit=100&order=-updatedAt"
            static let methodForStudentLocations = "https://parse.udacity.com/parse/classes/StudentLocation"
        }
        
        struct ApiKeys{
            static let parseApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
            static let parseRestApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
            static let createdAt = "createdAt"
            static let updatedAt = "updatedAt"
            static let results = "results"
            static let objectID = "objectId"
            static let uniqueKey = "uniqueKey"
            static let firstName = "firstName"
            static let lastName = "lastName"
            static let mapString = "mapString"
            static let mediaUrl = "mediaURL"
            static let latitude = "latitude"
            static let longitude = "longitude"
            
        }
    }
    
    struct HTTPMethods{
        static let put = "PUT"
        static let post = "POST"
    }
}
