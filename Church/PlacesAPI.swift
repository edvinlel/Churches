//
//  PlacesAPI.swift
//  Church
//
//  Created by Edvin Lellhame on 6/18/17.
//  Copyright © 2017 Edvin Lellhame. All rights reserved.
//

import Foundation
import GooglePlaces
import Alamofire
import CoreLocation
//
//enum PlacesError: String {
//	static let noInternet = "Internet is down."
//}

struct PlacesAPI {
	//let placesClient: GMSPlacesClient!
	
	static func getURLString(withCoordinates coordinate: CLLocationCoordinate2D, searchKey: String, nextPageToken: String) -> String {
		return "https://maps.googleapis.com/maps/api/place/search/json?location=\(coordinate.latitude),\(coordinate.longitude)&radius=8000&types=\(searchKey)&hasNextPage=true&nextPage()=true&sensor=false&key=\(APIKeys.apiKey)&pagetoken=\(nextPageToken)"
	}
	
	static func loadImageFromMetaData(placesClient: GMSPlacesClient, photo: GMSPlacePhotoMetadata, completion: @escaping (UIImage?) -> Void) {
		placesClient.loadPlacePhoto(photo) { (photo, error) in
			if error != nil {
				completion(nil)
				return
			}
			
			if let photo = photo {
				completion(photo)
			}
		}
	}
	
	private static func initializeChurch(withPlace place: GMSPlace?, image: UIImage?, address: String?, completionHandlerForChurch: @escaping (_ church: Church) -> Void) {
		guard let placeID = place?.placeID else {
			print("No place id returned")
			return
		}

		guard let name = place?.name else {
			print("No Name details for")
			return
		}

		guard let fullAddress = place?.formattedAddress else {
			print("No address details for")
			return
		}

		guard let website = place?.website else {
			print("No website details for")
			return
		}

		guard let number = place?.phoneNumber else {
			print("No numer details for")
			return
		}

		guard let coordinate = place?.coordinate else {
			print("No cordinate details for")
			return
		}

		let church = Church(placeId: placeID, name: name, address: address!, fullAddress: fullAddress, website: String(describing: website), phoneNumber: number, profileImage: image, coordinate: coordinate)
		completionHandlerForChurch(church)
	}

	
	

	static func lookupPlaceId(placesClient: GMSPlacesClient, placeId: String, address: String?, completionHandlerForChurch: @escaping (_ church: Church) -> Void) {
		placesClient.lookUpPlaceID(placeId) { (place, error) in
			guard error == nil else {
				print(error?.localizedDescription as Any)
				return
			}
			placesClient.lookUpPhotos(forPlaceID: placeId) { (results, error) in
				
				if let firstPhoto = results?.results.first {
					let _ = self.loadImageFromMetaData(placesClient: placesClient, photo: firstPhoto, completion: { (image) in
						DispatchQueue.main.async(execute: {
							var imageToPass = UIImage()
							if let image = image {
								imageToPass = image
							}
							initializeChurch(withPlace: place, image: imageToPass, address: address!, completionHandlerForChurch: completionHandlerForChurch)
						})
					})
				} else {
					initializeChurch(withPlace: place, image: nil, address: address!, completionHandlerForChurch: completionHandlerForChurch)
			
				}
			}
		}
	}

}
