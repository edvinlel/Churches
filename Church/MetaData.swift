//
//  MetaData.swift
//  Church
//
//  Created by Edvin Lellhame on 6/13/17.
//  Copyright © 2017 Edvin Lellhame. All rights reserved.
//

import Foundation
import GooglePlaces

protocol MetaDataImage {
	func lookupPlaceId(placeId: String, address: String?)
	func loadImageFromMetaData(photo: GMSPlacePhotoMetadata, completion: @escaping (UIImage?) -> Void)
}
