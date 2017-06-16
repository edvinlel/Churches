//
//  ChurchTableViewController.swift
//  Church
//
//  Created by Edvin Lellhame on 6/6/17.
//  Copyright © 2017 Edvin Lellhame. All rights reserved.
//

import UIKit
import GooglePlaces
import CoreLocation
import GoogleMaps
import Alamofire


class ChurchTableViewController: UIViewController, MetaDataImageProtocol {
	
	// MARK: - IBOutlet(s)
	@IBOutlet weak var tableView: UITableView!
	
	
	
	// MARK: - Properties
	var churches = [Church]()
	fileprivate let church = "church"
	
	var btn = UIBarButtonItem()
	var nextPageToken = String()        // use that variable to save a next page token to get next 20 record if have
	var lastNextPageToken = String()    // user that veriabe to check new token is not same
	var currentChurchSelected: Church!
	
	var placesClient: GMSPlacesClient!
	var placeId = ""
	
	var locationManager = CLLocationManager()
	var coordinate = CLLocationCoordinate2D()
	
	var resultsViewController: GMSAutocompleteResultsViewController?
	var searchController: UISearchController?
	var resultView: UITextView?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		locationManager.requestWhenInUseAuthorization()
		locationManager.startUpdatingLocation() // use start update location if location not yet start updating to get user current locaton
		
		placesClient = GMSPlacesClient.shared()
		
		
		coordinate = (locationManager.location?.coordinate)!
		
		// here following i added nextPagetToken, when app launch there is nil so get first 20 record and that same method we pass for load more
		queryGooglePlaces(googleSearchKey: church, nextPageToken: self.nextPageToken, location: coordinate)
		
		
		//Following i added a refresh button in case we did not get location or we are moving to other location by refresh button that record going to be refresh based on current location
		btn = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.refresh, target: self, action: #selector(refreshLocation))
		btn.tintColor = UIColor.black
		self.navigationItem.rightBarButtonItem = btn;
		
		/// Initialize and set delegate for ResultsViewController
		resultsViewController = GMSAutocompleteResultsViewController()
		resultsViewController?.delegate = self
		
		/// Initialize the SearchController and set resultsViewController
		searchController = UISearchController(searchResultsController: resultsViewController)
		searchController?.searchResultsUpdater = resultsViewController
		
		// Put the search bar in the navigation bar.
		searchController?.searchBar.sizeToFit()
		navigationItem.titleView = searchController?.searchBar
		
		// When UISearchController presents the results view, present it in
		// this view controller, not one further up the chain.
		definesPresentationContext = true
		
		// Prevent the navigation bar from being hidden when searching.
		searchController?.hidesNavigationBarDuringPresentation = false
	}
	
	fileprivate func clearTokensAndChurches() {
		self.lastNextPageToken  = ""  // Clears the last saved search token
		self.nextPageToken = "" // Clears the next page token
		self.churches.removeAll() // Remove all contents of the array
	}
	
	func refreshLocation() {
		/// This method user to refresh data for get new record and that will be called on tap refresh button
		clearTokensAndChurches()
		locationManager.startUpdatingLocation()
		
		queryGooglePlaces(googleSearchKey: church, nextPageToken: self.nextPageToken, location: self.coordinate)
	}
	
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
	
	
	func lookupPlaceId(placeId: String, address: String?) {
		self.placesClient.lookUpPlaceID(placeId) { (place, error) in
			guard error == nil else {
				print(error?.localizedDescription as Any)
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
							
							let church = Church(placeId: placeId, name: name, address: address!, fullAddress: fullAddress, website: String(describing: website), phoneNumber: number, profileImage: imageToPass, coordinate: coordinate)
							
							self.churches.append(church)
							self.tableView.reloadData()
							
						})
					})
				} else {
					let church = Church(placeId: placeId, name: name, address: address!, fullAddress: fullAddress, website: String(describing: website), phoneNumber: number, profileImage: nil, coordinate: coordinate)
					self.churches.append(church)
					self.tableView.reloadData()
				}
			}
		}
	}
	
	fileprivate func queryGooglePlaces(googleSearchKey: String, nextPageToken: String, location: CLLocationCoordinate2D?) {
		// Build the url string to send to Google.
		self.nextPageToken = nextPageToken // here are allocated next page token to last one that will be user at scroll method
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
				//self.placeId = placeId
				
				self.lookupPlaceId(placeId: placeId, address: address)
			}
		}
	}
	
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "DetailSegue" {
			let detailVC = segue.destination as! DetailViewController
			detailVC.currentChurch = currentChurchSelected
		}
	}
}

extension ChurchTableViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return churches.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "ChurchCell", for: indexPath) as! ChurchCell
		
		let church = churches[indexPath.row]
		cell.configureCell(church: church)
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let church = churches[indexPath.row]
		currentChurchSelected = church
		performSegue(withIdentifier: "DetailSegue", sender: self)
	}
	
	
}

// MARK: - UIScrollViewDelegate
extension ChurchTableViewController: UIScrollViewDelegate {
	// following method we use to get load more data here in that method will be fire on scroll
	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		// following code i am calculate offset of tableview scroll and do if condition is we reached at bottom or not
		let currentOffset = scrollView.contentOffset.y
		let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
		
		if maximumOffset - currentOffset <= 10.0 {
			// here i have check that next page token must be not same of last one other wise it will get same data again adn again so the following condition use to check that and else parse send a new request to get next 20 record
			if self.nextPageToken == self.lastNextPageToken {
				return
			} else {
				queryGooglePlaces(googleSearchKey: church, nextPageToken: self.nextPageToken, location: self.coordinate)
			}
		}
	}
	
}

// MARK: - GMSAutocompleteResultsViewControllerDelegate
extension ChurchTableViewController: GMSAutocompleteResultsViewControllerDelegate {
	func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didAutocompleteWith place: GMSPlace) {
		searchController?.isActive = false
		// Do something with the selected place.
		guard let address = place.formattedAddress else {
			print("error getting address in resultsController didAutoCompleteWith")
			return
		}
		let geocoder = CLGeocoder()
		geocoder.geocodeAddressString(address) { (placemarks, error) in
			if let placemark = placemarks?.first {
				DispatchQueue.main.async(execute: {
					self.clearTokensAndChurches()
					self.coordinate = (placemark.location?.coordinate)!
					self.queryGooglePlaces(googleSearchKey: self.church, nextPageToken: self.nextPageToken, location: self.coordinate)
				})
			}
		}
	}
	
	func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didFailAutocompleteWithError error: Error) {
		// TODO: handle the error.
		print("Error: ", error.localizedDescription)
	}
	
	// Turn the network activity indicator on and off again.
	func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
	}
	
	func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
		UIApplication.shared.isNetworkActivityIndicatorVisible = false
	}
}
























