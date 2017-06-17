//
//  Location+CoreDataProperties.swift
//  Church
//
//  Created by Edvin Lellhame on 6/17/17.
//  Copyright © 2017 Edvin Lellhame. All rights reserved.
//

import Foundation
import CoreData


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var location: String?
    @NSManaged public var churches: Church?

}
