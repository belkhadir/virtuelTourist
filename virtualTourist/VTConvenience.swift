//
//  VTConvenience.swift
//  virtualTourist
//
//  Created by Anas Belkhadir on 19/12/2015.
//  Copyright © 2015 Anas Belkhadir. All rights reserved.
//

import Foundation

extension VTClient {
    

    
    func searchingImageByLONLAT(latitude: Double,Longtitude:Double, completionHandler: (data: [[String: AnyObject]]? , success: Bool) -> Void){
        guard validLatitude(latitude) && validLongtitude(Longtitude) else{
            completionHandler(data: nil, success: false)
            return
        }

        let parameters: [String: AnyObject] = [
            VTClient.Parameters.METHOD : VTClient.Method.SEARCH,
            VTClient.Parameters.API_KEY : VTClient.Constants.API_KEY,
            VTClient.Parameters.BBOX : creatBoundingBoxString(latitude, longitude: Longtitude),
            VTClient.Parameters.SAFE_SEARCH : "1" ,
            VTClient.Parameters.EXTRAT : "url_m" ,
            VTClient.Parameters.FORMAT : "json" ,
            VTClient.Parameters.NOJSONCALLBACK : "1",
            
        ]
        VTClient.sharedVTClient().taskMethod(parameters){
            (result, error) in
            
            guard error == nil else{
                completionHandler(data: nil, success: false)
                return
            }
            guard let result = result else{
                completionHandler(data: nil, success: false)
                return
            }

            if let photoDictionary = result.valueForKey(VTClient.JsonKeys.PHOTOS) as? NSDictionary {
                if let totalPages = photoDictionary.valueForKey("pages") as? Int {
                    let pageLimit = min(totalPages, 40)
                    let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
                    self.getImageFromFlickrBySearchWithPage(parameters, resultByNumberOfPage: randomPage){
                        (images, success) in
                        if success{
                        completionHandler(data: images, success: true)
                        }else{
                            completionHandler(data: nil, success: false)
                        }
                    }
                }else{
                    completionHandler(data: nil, success: false)
                }
            }else{
                completionHandler(data: nil, success: false)
            }
        }
        
    }
    
    func getImageFromFlickrBySearchWithPage(method: [String: AnyObject],resultByNumberOfPage page: Int ,completionHandler: (images: [[String: AnyObject]]?, success: Bool) -> Void) {
        var methodParameter = method
        methodParameter["page"]    = page
        VTClient.sharedVTClient().taskMethod(methodParameter){
            (result, error) in
            guard error == nil else{
                completionHandler(images: nil, success: false)
                return
            }
            
            // unwraping result
            guard let result = result else {
                completionHandler(images: nil, success: false)
                return
            }
            
            if let photosDictionary = result.valueForKey(VTClient.JsonKeys.PHOTOS) as? NSDictionary {
                var totalPhotosVal = 0
                if let totalPhotos = photosDictionary["total"] as? String {
                    totalPhotosVal = (totalPhotos as NSString).integerValue
                }else{
                    completionHandler(images: nil, success: false)
                }
                
                if totalPhotosVal > 0 {
                    if let photosArray = photosDictionary["photo"] as? [[String: AnyObject]] {
                        completionHandler(images: photosArray, success: true)
                    }else{
                        completionHandler(images: nil, success: false)
                    }
                }else{
                    completionHandler(images: nil, success: false)
                }
            }else{
                completionHandler(images: nil, success: false)
            }
            
        }
    }
    
    func getSingleImageFromFlickr(WithURL url: String,completionHandler: (data: NSData?, success: Bool)->Void ){
        
        let URL = NSURL(string: url)
        if let data = NSData(contentsOfURL: URL!) {
            completionHandler(data: data, success: true)
        }else{
            completionHandler(data: nil, success: false)
        }
        
    }
    
    func creatImageIdentifier(dictionary: [String: AnyObject]) ->String {
        return "/\(dictionary[VTClient.JsonKeys.ID]!)_\(dictionary[VTClient.JsonKeys.SECRET]!).jpg"
    }
    
    func creatBoundingBoxString(latitude: Double, longitude: Double) -> String {
        
        let bottom_left_lon = max(longitude - BOUNDING_BOX_HALF_WIDTH, LON_MIN)
        let bottom_left_lat = max(latitude - BOUNDING_BOX_HALF_HEIGHT, LAT_MIN)
        let top_right_lon = min(longitude + BOUNDING_BOX_HALF_HEIGHT, LON_MAX)
        let top_right_lat = min(latitude + BOUNDING_BOX_HALF_HEIGHT, LAT_MAX)
        
        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
    }
    
    func validLatitude(latitude: Double) -> Bool{
        if latitude < LAT_MIN || latitude > LAT_MAX {
            return false
        }else{
            return true
        }
    }
    
    func validLongtitude(longitude: Double) -> Bool {
        if longitude < LAT_MIN || longitude > LAT_MAX {
            return false
        }else{
            return true
        }
        
    }


}