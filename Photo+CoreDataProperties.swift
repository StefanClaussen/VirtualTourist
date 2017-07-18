//
//  Photo+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Stefan Claussen on 18/07/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var photoID: String?
    @NSManaged public var remoteURL: NSURL?
    @NSManaged public var title: String?
    @NSManaged public var dateTaken: NSDate?

}
