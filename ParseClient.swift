//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Donny Blaine on 12/19/16.
//  Copyright © 2016 RyStudios. All rights reserved.
//

import Foundation
import UIKit

class ParseClient: NSObject{
    let session = URLSession.shared
    
    private override init() {}
    
    func getAllStudentLocations(completionHandler: @escaping (_ location: [[String: AnyObject]]?, _ error: String?) -> Void){
        let request = NSMutableURLRequest(url: URL(string: Constants.ParseConstants.UrlConstants.methodForStudentLocations)!)
        request.addValue(Constants.ParseConstants.UrlConstants.parseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ParseConstants.UrlConstants.RESTAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            guard error == nil else{
                completionHandler(nil, "An error has occured")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else{
                return
            }
            
            guard statusCode >= 200 && statusCode <= 299 else{
                completionHandler(nil, "Error, Try again later")
                return
            }
            
            guard let data = data else{
                completionHandler(nil, "Data Error")
                return
            }
            
            self.convertData(data: data, completionHandlerForData: { (result, error) in
                guard error == nil else{
                    completionHandler(nil, "Data Error")
                    return
                }
                
                guard let result = result else{
                    completionHandler(nil, "Error parsing data")
                    return
                }
                
                guard let locations = result["results"] as? [[String:AnyObject]] else{
                    completionHandler(nil, "Error parsing locations")
                    return
                }
                completionHandler(locations, nil)
            })
        }
        task.resume()
    }
    
    
    func putOrPostStudentLocation(student: StudentInformation, httpMethod: String, objectId: String?, completionHandler: @escaping (_ success: Bool, _ error: String?) -> Void) {
        
        var stringUrl = String()
        if httpMethod == Constants.HTTPMethods.put{
            if let objectId = objectId{
                stringUrl = "\(Constants.ParseConstants.UrlConstants.methodForStudentLocations)/\(objectId)"
            }
        }else{
            stringUrl = Constants.ParseConstants.UrlConstants.methodForStudentLocations
        }
        
        let url = URL(string: stringUrl)
        var request = URLRequest(url: url!)
        request.httpMethod = httpMethod
        request.addValue(Constants.ParseConstants.ApiKeys.parseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ParseConstants.ApiKeys.parseRestApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(student.uniqueKey)\", \"firstName\": \"\(student.firstName)\", \"lastName\": \"\(student.lastName)\",\"mapString\": \"\(student.mapString!)\", \"mediaURL\": \"\(student.mediaURL)\",\"latitude\": \(student.latitude), \"longitude\": \(student.longitude)}".data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else{
                completionHandler(false, "An error has occured")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else{
                return
            }
            
            guard statusCode >= 200 && statusCode <= 299 else{
                completionHandler(false, "Error, Try again later")
                return
            }
            
            guard let data = data else{
                completionHandler(false, "Data Error")
                return
            }
            
            self.convertData(data: data, completionHandlerForData: { (result, error) in
                guard error == nil else{
                    completionHandler(false, "Data Error")
                    return
                }
                
                guard let result = result else{
                    completionHandler(false, "Error parsing data")
                    return
                }
                
                guard (result[Constants.ParseConstants.ApiKeys.createdAt] as? String) != nil || (result[Constants.ParseConstants.ApiKeys.updatedAt] as? String) != nil else{
                    completionHandler(false, "Error parsing data")
                    return
                }
                completionHandler(true, nil)
            })
        }
        task.resume()
    }
    
    
    
    private func convertData(data: Data, completionHandlerForData:(_ result: AnyObject?, _ error: NSError?) -> Void){
        var parsedData: AnyObject? = nil
        do{
            parsedData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
            
        }catch{
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForData(nil, NSError(domain: "convertData", code: 1, userInfo: userInfo))
        }
        completionHandlerForData(parsedData, nil)
    }
    
    class func sharedInstance() -> ParseClient {
        struct Singleton{
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }
}

