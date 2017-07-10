//
//  Favorite.swift
//  Church
//
//  Created by Edvin Lellhame on 6/17/17.
//  Copyright © 2017 Edvin Lellhame. All rights reserved.
//

import Foundation
import CoreData

class Favorite: NSManagedObject {
	@NSManaged var favoriteId: String?
	@NSManaged var isFavorite: Bool
}
