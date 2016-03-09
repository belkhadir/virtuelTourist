//
//  VTClient.swift
//  virtualTourist
//
//  Created by Anas Belkhadir on 19/12/2015.
//  Copyright © 2015 Anas Belkhadir. All rights reserved.
//

import Foundation

let BOUNDING_BOX_HALF_WIDTH = 1.0
let BOUNDING_BOX_HALF_HEIGHT = 1.0
let LAT_MIN = -90.0
let LAT_MAX = 90.0
let LON_MIN = -180.0
let LON_MAX = 180.0

class VTClient: NSObject {
    
    var session: NSURLSession
   
    override init(){
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    struct Cache {
        static let imageCache = ImageCache()
    }
    
    func taskMethod(parameters: [String: AnyObject],completionHandler: (result: AnyObject?, error: ErrorType?) -> Void) -> NSURLSessionDataTask{
        
        let parameter = parameters
        
        let urlString: String = VTClient.Constants.BASE_URL + VTClient.escapedParameter(parameter)
        
        let url = NSURL(string: urlString)
        
        let request = NSURLRequest(URL: url!)
        
        let task = session.dataTaskWithRequest(request){ (data, response, error) in
            
            guard error == nil else{
                return
            }
            
            VTClient.statusCodeWithCompletionHandler(response!){
                success in
                if !success{
                    return
                }
            }
            
            guard let data = data else{
                print("no data was returned")
                return
            }
            VTClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            
        }
        
        task.resume()
        return task
    }
    
    
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject?, error: ErrorType?) -> Void) {
        var parsedResult: AnyObject!
        
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        }catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandler(result: nil, error: NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandler(result: parsedResult, error: nil)
    }
    
    class func statusCodeWithCompletionHandler(response: AnyObject, completionHandler: (success: Bool) -> Void){
        guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
            if let response = response as? NSHTTPURLResponse {
                print("Your request returned an invalid response! Status code: \(response.statusCode)!")
            } else {
                print("Your request returned an invalid response!")
            }
            completionHandler(success: false)
            return
        }
        completionHandler(success: true)
        
    }
    
    class func escapedParameter(parameters: [String: AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key,value) in parameters {
            
            let stringVlue = "\(value)"
            
            let escapedPrameter = stringVlue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            urlVars += [ key + "=" + "\(escapedPrameter!)"]
        }
        
        return (!urlVars.isEmpty ? "?": "") + urlVars.joinWithSeparator("&")
        
    }
    
    
    
    
    class func sharedVTClient() -> VTClient {
        struct Singleton {
            static var sharedVTClient = VTClient()
        }
        return Singleton.sharedVTClient
    }
    
    
    
}