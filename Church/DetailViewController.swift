//
//  DetailViewController.swift
//  Church
//
//  Created by Edvin Lellhame on 6/13/17.
//  Copyright © 2017 Edvin Lellhame. All rights reserved.
//

import UIKit
import MapKit
import GooglePlaces

class DetailViewController: UIViewController, MetaDataImage {

	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var websiteLabel: UIButton!
	@IBOutlet weak var phoneLabel: UIButton!
	@IBOutlet weak var addresslabel: UIButton!
	
	var currentChurch: Church!
	var placesClient: GMSPlacesClient!
	
	override func viewDidLoad() {
		super.viewDidLoad()

		configureLabels()
		addAnotation()
		navigationItem.title = currentChurch.name

		placesClient = GMSPlacesClient()
	
		
	}
	
	func configureLabels() {
		if let website = currentChurch?.website {
			websiteLabel.setTitle(website, for: .normal)
		}
		
		if let phoneNumber = currentChurch?.phoneNumber {
			phoneLabel.setTitle(phoneNumber, for: .normal)
		}
		
		addresslabel.setTitle(currentChurch?.fullAddress, for: .normal)
	}
	
	func addAnotation() {
		DispatchQueue.main.async { 
			let annotation = MKPointAnnotation()
			annotation.coordinate = self.currentChurch.coordinate
			self.mapView.addAnnotation(annotation)
			
			let span = MKCoordinateSpanMake(0.01, 0.01)
			let region = MKCoordinateRegionMake(annotation.coordinate, span)
			self.mapView.setRegion(region, animated: false)
		}
		
	}
	
	func loadImageFromMetaData(photo: GMSPlacePhotoMetadata, completion: @escaping (UIImage?) -> Void) {
		placesClient.lookUpPhotos(forPlaceID: currentChurch.placeId) { (photos, error) in
		
		}
	}
	
	func lookupPlaceId(placeId: String, address: String?) {
		placesClient.lookUpPlaceID(currentChurch.placeId) { (places, error) in
			guard error == nil else {
				print("error in looking up place in detail view conttoller")
				return
			}
		}
	}
	func viewItnig() {
		lookupPlaceId(placeId: currentChurch.placeId, address: nil)
	}
	
	/*
	
	func loadImageFromMetaData(photo: GMSPlacePhotoMetadata, completion: @escaping (UIImage?) -> Void) {
	placesClient.loadPlacePhoto(photo) { (photo, error) in
	if error != nil {
	print("Image nil")
	completion(nil)
	return
	}
	
	if let photo = photo {
	completion(photo)
	}
	}
	}
	
	func lookupPlaceId(placeId: String, address: String) {
	placesClient.lookUpPlaceID(placeId) { (place, error) in
	guard error == nil else {
	print(error?.localizedDescription as Any)
	return
	}
	
	let name = place?.name
	let fullAddress = place?.formattedAddress
	let website = place?.website
	let number = place?.phoneNumber
	let coordinate = place?.coordinate
	/*
	followig your created if condition code i need to remove we can not make a necessory if condition for church some of have no web url some of not phone number so for getting all the church data we need to remve if condition and try to get photos if have other wise pass "" value
	*/
	self.placesClient.lookUpPhotos(forPlaceID: placeId) { (results, error) in
	if let firstPhoto = results?.results.first {
	let _ = self.loadImageFromMetaData(photo: firstPhoto, completion: { (image) in
	DispatchQueue.main.async(execute: {
	var imageToPass = UIImage()
	if let image = image {
	imageToPass = image
	} else {
	imageToPass = UIImage(named: "placeholder")!
	}
	
	let church = Church(placeId: placeId, name: name!, address: address, fullAddress: fullAddress!, website: String(describing: website), phoneNumber: number, profileImage: imageToPass, coordinate: coordinate!)
	
	self.churches.append(church)
	
	self.tableView.reloadData()
	
	})
	})
	} else {
	let church = Church(placeId: placeId, name: name!, address: address, fullAddress: fullAddress!, website: String(describing: website), phoneNumber: number, profileImage: nil, coordinate: coordinate!)
	self.churches.append(church)
	
	self.tableView.reloadData()
	}
	}
	
	}
	}
	
	fileprivate func queryGooglePlaces(googleSearchKey: String, nextPageToken: String, location: CLLocationCoordinate2D?) {
	// Build the url string to send to Google.
	self.lastNextPageToken = nextPageToken // here are allocated next page token to last one that will be user at scroll method
	guard let latitude = location?.latitude,
	let longitude = location?.longitude else {
	
	return
	}
	// in following i added pagetoken parameter to get a next page of records.
	let url = "https://maps.googleapis.com/maps/api/place/search/json?location=\(latitude),\(longitude)&radius=8000&types=\(googleSearchKey)&hasNextPage=true&nextPage()=true&sensor=false&key=\(Constants.apiKey)&pagetoken=\(nextPageToken)"
	
	
	Alamofire.request(url).responseJSON { (response) in
	guard let json = response.result.value as? [String: Any] else {
	print("error in json")
	return
	}
	// in following method i store the next page token that will be pass when user scroll to down of the tableview
	if json.index(forKey: "next_page_token") != nil {
	// the key exists in the dictionary
	self.nextPageToken = json["next_page_token"] as! String
	}
	
	guard let results = json["results"] as? [[String: Any]] else {
	print("error in results")
	return
	}
	
	for i in results {
	guard let placeId = i["place_id"] as? String else {
	print("error in placeId")
	return
	}
	
	guard let address = i["vicinity"] as? String else {
	print("error in address")
	return
	}
	
	self.lookupPlaceId(placeId: placeId, address: address)
	}
	}
	}

	
	
	*/
	
	@IBAction func onAddressButtonPressed(_ sender: Any) {
	}

	@IBAction func onWebsiteButtonPressed(_ sender: Any) {
	}
	
	@IBAction func onPhoneNumberButtonPressed(_ sender: Any) {
	}
}
