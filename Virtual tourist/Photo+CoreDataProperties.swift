//
//  Photo+CoreDataProperties.swift
//  Virtual tourist
//
//  Created by Dirk Milotz on 1/29/17.
//  Copyright © 2017 Dirk Milotz. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo");
    }

    @NSManaged public var creationDate: NSDate?
    @NSManaged public var imgData: NSData?
    @NSManaged public var pin: Pin?

}
