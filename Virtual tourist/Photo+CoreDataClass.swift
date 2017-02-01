//
//  Photo+CoreDataClass.swift
//  Virtual tourist
//
//  Created by Dirk Milotz on 1/29/17.
//  Copyright © 2017 Dirk Milotz. All rights reserved.
//

import Foundation
import CoreData

@objc(Photo)
public class Photo: NSManagedObject {

    convenience init(img: NSData, context: NSManagedObjectContext) {
        
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        if let ent = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
            self.init(entity: ent, insertInto: context)
            self.imgData = img
            self.creationDate = Date() as NSDate?
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
    
    
    convenience init(url: String,  context: NSManagedObjectContext) {
        
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        if let ent = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
            self.init(entity: ent, insertInto: context)
            self.url = url
        
            self.creationDate = Date() as NSDate?
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
    
}
