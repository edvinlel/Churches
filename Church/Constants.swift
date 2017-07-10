//
//  Constants.swift
//  Church
//
//  Created by Edvin Lellhame on 6/7/17.
//  Copyright © 2017 Edvin Lellhame. All rights reserved.
//

import Foundation

enum APIKeys {
	static let apiKey = "AIzaSyB7LeBUvcbvxsHNWD8K0-nK_9S6ZuFg_Is"
}

enum JSONKeys {
	static let nextPageToken = "next_page_token"
	static let results = "results"
	static let placeId = "place_id"
	static let vicinity = "vicinity"
}

enum Identifiers {
	static let churchCellIdentifier = "ChurchCell"
	static let detailCellIdentifier = "DetailCell"
	static let detailSegue = "DetailSegue"
	static let imageSegue = "ImageSegue"
	static let noInternetVC = "NoInternetVC"
}

enum ImageNames {
	static let star = "star"
	static let filledStar = "filled_star"
}
