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

struct Churches {
	// MARK: - Properties
	private var _placeId: String!
	private var _name: String!
	private var _fullAddress: String!
	private var _address: String!
	private var _website: String?
	private var _phoneNumber: String?
	private var _profileImage: UIImage?
	private var _coordinate: CLLocationCoordinate2D!
	private var _isFavorite: Bool!
	
	var placeId: String {
		return _placeId
	}
	
	var name: String {
		return _name
	}
	
	var fullAddress: String {
		return _fullAddress
	}
	
	var address: String {
		return _address
	}
	
	var website: String? {
		if let website = _website {
			return website
		} else {
			return "No website available."
		}
	}
	
	var phoneNumber: String? {
		if let phoneNumber = _phoneNumber {
			return phoneNumber
		} else {
			return "No phone number available"
		}
	}
	
	var profileImage: UIImage? {
		if let profileImage = _profileImage {
			return profileImage
		} else {
			return nil
		}
	}
	
	var coordinate: CLLocationCoordinate2D {
		return _coordinate
	}
	
	var isFavorite: Bool {
		get {
			return _isFavorite
		}
		set(flag) {
			_isFavorite = flag
		}
		
	}
	
	// MARK: - Initializer
	init(placeId: String, name: String, address: String, fullAddress: String, website: String?, phoneNumber: String?, profileImage: UIImage?, coordinate: CLLocationCoordinate2D) {
		_placeId = placeId
		_name = name
		_address = address
		_fullAddress = fullAddress
		_coordinate = coordinate
		
		if website != nil {
			_website = website
		}
		else {
			_website = nil
		}
		
		if phoneNumber != nil {
			_phoneNumber = phoneNumber
		} else {
			_phoneNumber = nil
		}
		
		if profileImage != nil {
			_profileImage = profileImage
		} else {
			_profileImage = nil
		}
		
		_isFavorite = false
	}
}
