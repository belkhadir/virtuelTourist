//
//  Pin.swift
//  virtualTourist
//
//  Created by Anas Belkhadir on 27/12/2015.
//  Copyright © 2015 Anas Belkhadir. All rights reserved.
//

import Foundation
import CoreData

class Pin: NSManagedObject{
    
    struct key {
        static let latitude = "latitude"
        static let longitude = "longitude"
    }
    
    
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    
    @NSManaged var pictures: [Photo]
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String: AnyObject],context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        if let newLatitude = dictionary[key.latitude]{
            latitude = newLatitude as! Double
            longitude = dictionary[key.longitude] as! Double

        }
    
    }
  
}