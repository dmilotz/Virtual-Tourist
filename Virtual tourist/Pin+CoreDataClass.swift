//
//  Pin+CoreDataClass.swift
//  Virtual tourist
//
//  Created by Dirk Milotz on 1/29/17.
//  Copyright © 2017 Dirk Milotz. All rights reserved.
//

import Foundation
import CoreData

@objc(Pin)
public class Pin: NSManagedObject {
    convenience init(title: String, longitude: Double, latitude: Double, context: NSManagedObjectContext) {
        
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        if let ent = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
            self.init(entity: ent, insertInto: context)
            self.longitude = longitude
            self.latitude = latitude
            self.creationDate = Date() as NSDate?
            self.locationName = title
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}
