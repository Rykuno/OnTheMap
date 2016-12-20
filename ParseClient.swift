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
    
    
    func getAllStudentLocations(completionHandler: @escaping (_ location: [[String: AnyObject]]?, _ error: String?) -> Void){
        let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
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

