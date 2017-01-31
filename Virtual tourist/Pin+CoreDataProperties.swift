//
//  Pin+CoreDataProperties.swift
//  Virtual tourist
//
//  Created by Dirk Milotz on 1/31/17.
//  Copyright © 2017 Dirk Milotz. All rights reserved.
//

import Foundation
import CoreData


extension Pin {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pin> {
        return NSFetchRequest<Pin>(entityName: "Pin");
    }

    @NSManaged public var creationDate: NSDate?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var locationName: String?
    @NSManaged public var photos: NSSet?

}

// MARK: Generated accessors for photos
extension Pin {

    @objc(addPhotosObject:)
    @NSManaged public func addToPhotos(_ value: Photo)

    @objc(removePhotosObject:)
    @NSManaged public func removeFromPhotos(_ value: Photo)

    @objc(addPhotos:)
    @NSManaged public func addToPhotos(_ values: NSSet)

    @objc(removePhotos:)
    @NSManaged public func removeFromPhotos(_ values: NSSet)

}
