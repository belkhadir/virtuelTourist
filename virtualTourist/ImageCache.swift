//
//  ImageCache.swift
//  virtualTourist
//
//  Created by Anas Belkhadir on 04/01/2016.
//  Copyright © 2016 Anas Belkhadir. All rights reserved.
//

import UIKit

class ImageCache {
    
    private var inMemoryCache = NSCache()
    
    // Retrive Image 
    
    func imageWithIdentifier(identifier: String?) -> UIImage? {
        
        if identifier == nil || identifier == "" {
            return nil
        }
        
        let path = pathForIdentifier(identifier!)
        
        if let image = inMemoryCache.objectForKey(path) as? UIImage{
            return image
        }
        
        if let data = NSData(contentsOfFile: path){
            return UIImage(data: data)
        }
        return nil
        
    }
    
    //Removing Image 
    
    func removeImage(identifier: String){
        
        let path = pathForIdentifier(identifier)
        
        if NSFileManager.defaultManager().fileExistsAtPath(path) {
            do{
                try NSFileManager.defaultManager().removeItemAtPath(path)
            }catch {
                print("couldn't remove Photo")
                return
            }
        }else{
            print("couldn't remove Photo")
            return
        }
        
    }
    
    
    
    // Saving Image
    
    func storeImage(image: UIImage?, withIdentifier identifier: String){
        
        let path = pathForIdentifier(identifier)
        
        if image == nil {
            inMemoryCache.removeObjectForKey(path)
            do{
                try NSFileManager.defaultManager().removeItemAtPath(path)
            }catch _{}
            return
        }
        inMemoryCache.setObject(image!, forKey: path)
        
        let data = UIImagePNGRepresentation(image!)
        data?.writeToFile(path, atomically: true)
    }
    
    
    
    // creat path
    private func pathForIdentifier(identifier: String) -> String {
        let documentDirectory: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let fullURL = documentDirectory.URLByAppendingPathComponent(identifier)
        return fullURL.path!
    }
}