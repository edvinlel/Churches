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

class DetailViewController: UIViewController, MetaDataImageProtocol {

	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var websiteLabel: UIButton!
	@IBOutlet weak var phoneLabel: UIButton!
	@IBOutlet weak var addresslabel: UIButton!
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var imagesAvailableLabel: UILabel!

	
	var currentChurch: Churches!
	var placesClient: GMSPlacesClient!
	
	var churchImages = [UIImage]()
	
	var selectedImage = UIImage()
	
	override func viewDidLoad() {
		super.viewDidLoad()

		configureLabels()
		addAnotation()
		
		navigationItem.title = currentChurch.name
		navigationController?.navigationBar.tintColor = UIColor.navy()
		
		collectionView.collectionViewLayout = CustomImageFlowLayout()

		placesClient = GMSPlacesClient()
		
		lookupPlaceId(placeId: currentChurch.placeId, address: nil)

	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	
		if churchImages.count != 0 {
			imagesAvailableLabel.text = ""
		} else {
			imagesAvailableLabel.isHidden = false
			imagesAvailableLabel.text = "Checking for images."
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		guard currentChurch.profileImage != nil else {
			imagesAvailableLabel.text = "No images available."
			return
		}
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
		placesClient.loadPlacePhoto(photo) { (image, error) in
			if error != nil {
				print("error in loadImageFromMetaData")
				DispatchQueue.main.async(execute: { 
					self.imagesAvailableLabel.isHidden = false
					self.imagesAvailableLabel.text = "No images available."
				})
				completion(nil)
			}
			
			completion(image)
		}
	}
	
	func lookupPlaceId(placeId: String, address: String?) {
		placesClient.lookUpPlaceID(currentChurch.placeId) { (places, error) in
			guard error == nil else {
				print("error in looking up place in detail view conttoller")
				return
			}
			
			self.placesClient.lookUpPhotos(forPlaceID: placeId, callback: { (results, error) in
				guard let results = results?.results else {
					print("error getting photos")
					return
				}
				for i in results {
					let _ = self.loadImageFromMetaData(photo: i, completion: { (image) in
						
						guard let image = image else {
//							DispatchQueue.main.async {
//								self.imagesAvailableLabel.isHidden = false
//								self.imagesAvailableLabel.text = "No images available."
//							}
							print("nooooo images hereeeeeee")
							return
						}
//						DispatchQueue.main.async(execute: {
//							self.churchImages.append(image)
//							self.imagesAvailableLabel.text = ""
//							self.imagesAvailableLabel.isHidden = true
//							self.collectionView.reloadData()
//							
//						})
						self.churchImages.append(image)
						self.imagesAvailableLabel.text = ""
						self.imagesAvailableLabel.isHidden = true
						self.collectionView.reloadData()
					})
				}
			})
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "imageSegue" {
			let imageVC = segue.destination as! ImagePresentedViewController
			imageVC.selectedImage = selectedImage
		}
	}

	
	@IBAction func onAddressButtonPressed(_ sender: Any) {
		let regionDistance:CLLocationDistance = 10000
		let coordinates = CLLocationCoordinate2DMake(currentChurch.coordinate.latitude, currentChurch.coordinate.longitude)
		let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
		let options = [
			MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
			MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
		]
		let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
		let mapItem = MKMapItem(placemark: placemark)
		mapItem.name = currentChurch.name
		mapItem.phoneNumber = currentChurch.phoneNumber
		mapItem.openInMaps(launchOptions: options)
	}

	@IBAction func onWebsiteButtonPressed(_ sender: Any) {
		if let url = URL(string: currentChurch.website!) {
			if VerifyURL.verifyURL(address: currentChurch.website) {
				if #available(iOS 10, *) {
					UIApplication.shared.open(url)
				} else {
					UIApplication.shared.openURL(url)
				}
			}
		}
	}
	
	@IBAction func onPhoneNumberButtonPressed(_ sender: Any) {
		guard let phoneNumber = currentChurch.phoneNumber else {
			print("errrrrror calling")
			return
		}
		let result = String(phoneNumber.characters.filter { "01234567890.".characters.contains($0) })
		if let url:URL = URL(string: "tel://\(result)"), UIApplication.shared.canOpenURL(url) {
			if #available(iOS 10, *) {
				UIApplication.shared.open(url)
			} else {
				UIApplication.shared.openURL(url)
			}
		} else {
			print("error getting url for number")
		}
	}

	
	override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
		return false
	}
}

extension DetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return churchImages.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! DetailImageCell
		
		cell.imageView.image = churchImages[indexPath.row]

		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		selectedImage = churchImages[indexPath.row]
		performSegue(withIdentifier: "imageSegue", sender: self)
	}
}















