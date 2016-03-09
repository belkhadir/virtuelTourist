//
//  Photos.swift
//  virtualTourist
//
//  Created by Anas Belkhadir on 27/12/2015.
//  Copyright © 2015 Anas Belkhadir. All rights reserved.
//

import UIKit
import CoreData

class Photo: NSManagedObject {
    
    @NSManaged var imagePath: String?
    @NSManaged var url: String?
    @NSManaged var pin: Pin
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(imagePath: String,url: String,context: NSManagedObjectContext){
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        self.imagePath = imagePath
        self.url = url
    }

    var image: UIImage? {
        set{
            VTClient.Cache.imageCache.storeImage(image, withIdentifier: imagePath!)
        }
        get {
            return VTClient.Cache.imageCache.imageWithIdentifier(imagePath!)
        }
    }
    
    func removeImage(){
        VTClient.Cache.imageCache.removeImage(imagePath!)
    }
    

}