//
//  Church+CoreDataProperties.swift
//  Church
//
//  Created by Edvin Lellhame on 6/17/17.
//  Copyright © 2017 Edvin Lellhame. All rights reserved.
//

import Foundation
import CoreData


extension Church {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Church> {
        return NSFetchRequest<Church>(entityName: "Church")
    }

    @NSManaged public var placeId: String?
    @NSManaged public var name: String?
    @NSManaged public var fullAddress: String?
    @NSManaged public var address: String?
    @NSManaged public var website: String?
    @NSManaged public var phoneNumber: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var profileImage: NSData?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var location: Location?

}
