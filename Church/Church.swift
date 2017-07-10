//
//  Church.swift
//  Church
//
//  Created by Edvin Lellhame on 6/7/17.
//  Copyright © 2017 Edvin Lellhame. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

struct Church: Comparable {
	// MARK: - Properties
	public private(set) var placeId: String!
	public private(set) var name: String!
	public private(set) var fullAddress: String!
	public private(set) var address: String!
	public private(set) var website: String!
	public private(set) var phoneNumber: String?
	public private(set) var profileImage: UIImage?
	public private(set) var coordinate: CLLocationCoordinate2D!
	private var _isFavorite: Bool!

	var isFavorite: Bool {
		set {
			_isFavorite = newValue
		}
		get {
			return _isFavorite
		}
	}
	
	// MARK: - Initializer
	init(placeId: String, name: String, address: String, fullAddress: String, website: String?, phoneNumber: String?, profileImage: UIImage?, coordinate: CLLocationCoordinate2D) {
		self.placeId = placeId
		self.name = name
		self.address = address
		self.fullAddress = fullAddress
		self.coordinate = coordinate
		
		if website != nil {
			self.website = website
		}
		else {
			self.website = nil
		}
		
		if phoneNumber != nil {
			self.phoneNumber = phoneNumber
		} else {
			self.phoneNumber = nil
		}
		
		if profileImage != nil {
			self.profileImage = profileImage
		} else {
			self.profileImage = nil
		}
		
		self._isFavorite = false
	}

	
	static func <(lhs: Church, rhs: Church) -> Bool {
		return lhs.name < rhs.name
	}

	static func ==(lhs: Church, rhs: Church) -> Bool {
		return lhs.placeId == rhs.placeId
	}
}



