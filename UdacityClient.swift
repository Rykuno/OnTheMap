//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Donny Blaine on 12/18/16.
//  Copyright © 2016 RyStudios. All rights reserved.
//

import Foundation

class UdacityClient: NSObject{
    let session = URLSession.shared
    var accountKey: String = ""
    
    private override init() {}
    
    func postLoginSession(email:String, password: String, completionHandler: @escaping (_ success: Bool, _ error: String?) -> Void){
        let request = NSMutableURLRequest(url: URL(string: Constants.UdacityConstants.UrlConstants.methodForPostingSession)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}".data(using: String.Encoding.utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            guard error == nil else{
                print("An error has occured \(error)")
                completionHandler(false, "Check connection and try again")
                return
            }
            
            guard let data = data else{
                completionHandler(false, "Data Error")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else{
               return
            }
            
            guard statusCode >= 200 && statusCode <= 299 else{
                if (statusCode == 400 || statusCode == 403) {
                    print(statusCode)
                    completionHandler(false, "Check Username or Password")
                    return
                }else{
                    completionHandler(false, "Check your connection")
                    return
                }
            }
        
            let range = 5...data.count
            let newData = data.subdata(in: Range(range))
            
            self.convertData(data: newData, completionHandlerForData: { (result, error) in
                guard error == nil else{
                    completionHandler(false, "Error parsing data")
                    return
                }
                
                guard let result = result else{
                    completionHandler(false, "Error with data")
                    return
                }
                
                guard let account = result[Constants.UdacityConstants.ApiKeys.account] as? [String:AnyObject] else{
                    completionHandler(false, "Error parsing account")
                    return
                }
                
                guard let key = account[Constants.UdacityConstants.ApiKeys.key] as? String else{
                    completionHandler(false, "Error parsing key")
                    return
                }
                
                self.accountKey = key
                print(self.accountKey)
                completionHandler(true, nil)
            })
        }
        task.resume()
    }
    
    func deleteSession(completionHandler: @escaping (_ success: Bool, _ error: String?) -> Void){
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
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
            
            guard data != nil else{
                completionHandler(false, "Data Error")
                return
            }
            completionHandler(true, nil)
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
    
class func sharedInstance() -> UdacityClient{
    struct Singleton{
        static var sharedInstance = UdacityClient()
    }
    return Singleton.sharedInstance
    }
}
