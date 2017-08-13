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
import CoreData
import ReachabilitySwift

class ChurchTableViewController: UIViewController {
	
	// MARK: - IBOutlet(s)
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var starButton: UIButton!
	
	// MARK: - Properties
	var favoriteChurches = [Church]()
	var nonFavoriteChurches = [Church]()
	
	var favChurches = [Favorite]()
	
	// Constants
	let church = "church"
	
	// Core data
	var coreDataStack: CoreDataStack!
	
	// Google Places
	var nextPageToken = String()
	var lastNextPageToken = String()
	var placesClient: GMSPlacesClient!
	
	// Church
	var currentChurchSelected: Church!
	
	// CoreLocation
	var locationManager = CLLocationManager()
	var coordinate = CLLocationCoordinate2D()
	
	// Google Places search bar
	var resultsViewController: GMSAutocompleteResultsViewController?
	var searchController: UISearchController?
	var resultView: UITextView?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.

		coreDataStack = CoreDataStack.stack
		
		let fetchRequest: NSFetchRequest<Favorite> = NSFetchRequest<Favorite>(entityName: "Favorite")
		do {
			favChurches = try coreDataStack.managedContext.fetch(fetchRequest)
		} catch {
			print("error getting fav churches")
		}
		
		for i in favChurches {
			print("-------- fav churches church tableveiw --------")
			print(i.favoriteId)
		}
		
		locationManager.requestWhenInUseAuthorization()
		locationManager.startUpdatingLocation() // use start update location if location not yet start updating to get user current locaton
		
		placesClient = GMSPlacesClient.shared()
		
		coordinate = (locationManager.location?.coordinate)!

		/// Initialize and set delegate for ResultsViewController
		resultsViewController = GMSAutocompleteResultsViewController()
		resultsViewController?.delegate = self
		
		/// Initialize the SearchController and set resultsViewController
		searchController = UISearchController(searchResultsController: resultsViewController)
		searchController?.searchResultsUpdater = resultsViewController
		
		// Put the search bar in the navigation bar.
		searchController?.searchBar.sizeToFit()
		navigationItem.titleView = searchController?.searchBar
		
		searchController?.searchBar.placeholder = "Search City"
		
		// When UISearchController presents the results view, present it in
		// this view controller, not one further up the chain.
		definesPresentationContext = true
		
		// Prevent the navigation bar from being hidden when searching.
		searchController?.hidesNavigationBarDuringPresentation = false
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		ReachabilityManager.shared.addListener(listener: self)
		// here following i added nextPagetToken, when app launch there is nil so get first 20 record and that same method we pass for load more
		if nonFavoriteChurches.count == 0 {
			queryGooglePlaces(googleSearchKey: church, nextPageToken: self.nextPageToken, location: coordinate)
		}
	
		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		ReachabilityManager.shared.removeListener(listener: self)
	}
	
	// Mark: - Helper Method(s)
	func clearTokensAndChurches() {
		lastNextPageToken  = ""  // Clears the last saved search token
		nextPageToken = "" // Clears the next page token
		// Remove all contents of the array
		favoriteChurches = []
		nonFavoriteChurches = []
	}
	
	func appendChurch(_ church: Church) {
		if coreDataStack.isChurchFavorited(id: church.placeId) {
			favoriteChurches.append(church)
			favoriteChurches.sort { $0 < $1 }
	
		} else {
			nonFavoriteChurches.append(church)
		}
	}
	
	func queryGooglePlaces(googleSearchKey: String, nextPageToken: String, location: CLLocationCoordinate2D) {
		// Build the url string to send to Google.
		lastNextPageToken = nextPageToken // here are allocated next page token to last one that will be user at scroll method
	
	  let url = PlacesAPI.getURLString(withCoordinates: location, searchKey: church, nextPageToken: nextPageToken)
		
		let network = Network.get(url: url)
		network.request { (response) in
			switch response {
			case .success(response: let data):
				guard let json = data as? [String: Any] else {
					return
				}
				
				if json.index(forKey: JSONKeys.nextPageToken) != nil {
					// the key exists in the dictionary
					self.nextPageToken = json[JSONKeys.nextPageToken] as! String
				}
				
				guard let results = json[JSONKeys.results] as? [[String: Any]] else {
					print("error in results")
					return
				}
				
				// Parse json results and
				self.parse(json: results)
				
			case .error(error: _):
				self.initiateNoInternetViewController()
				
			}
		}
	}
	
	private func parse(json: [[String: Any]]) {
		for i in json {
			guard let placeId = i[JSONKeys.placeId] as? String else {
				print("error in placeId")
				return
			}
			
			guard let address = i[JSONKeys.vicinity] as? String else {
				print("error in address")
				return
			}
			
			PlacesAPI.lookupPlaceId(placesClient: self.placesClient, placeId: placeId, address: address, completionHandlerForChurch: { (church) in
				self.appendChurch(church)
				DispatchQueue.main.async(execute: {
					self.tableView.reloadData()
				})
			})
		}

	}
	
	func initiateNoInternetViewController() {
		let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
		let noInternetVC = storyboard.instantiateViewController(withIdentifier: Identifiers.noInternetVC)
		self.present(noInternetVC, animated: true, completion: nil)
	}

	// Mark: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == Identifiers.detailSegue {
			let detailVC = segue.destination as! DetailViewController
			detailVC.currentChurch = currentChurchSelected
		} else if segue.identifier == Identifiers.favoritesSegue {
			let detailVC = segue.destination as! FavoritesViewController
			detailVC.coreDataStack = coreDataStack
			detailVC.currentChurch = currentChurchSelected
			detailVC.favoriteChurches = favoriteChurches
			detailVC.placesClient = placesClient
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

// MARK: - ScrollViewDelegate
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

extension ChurchTableViewController: NetworkStatusListener {
	func networkStatusDidChange(status: Reachability.NetworkStatus) {
		
		switch status {
		case .notReachable:
			debugPrint("ViewController: Network became unreachable")
	
		case .reachableViaWiFi:
			debugPrint("ViewController: Network available through wifi")
		case .reachableViaWWAN:
			debugPrint("ViewController: Network available through cellular data")
		}
		
		let haveNetwork = !(status == .notReachable)
		
		if !haveNetwork {
			
		}
		
	}
}


















