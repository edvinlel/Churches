//
//  FavoritesViewController.swift
//  Church
//
//  Created by Edvin Lellhame on 8/12/17.
//  Copyright © 2017 Edvin Lellhame. All rights reserved.
//

import UIKit
import CoreData
import GooglePlaces

class FavoritesViewController: UIViewController {
	
	@IBOutlet weak var tableView: UITableView!
	
	var coreDataStack: CoreDataStack!
	var currentChurch: Church!
	var favoriteChurches: [Church]!
	var favChurches = [Favorite]()
	
	var placesClient: GMSPlacesClient!

    override func viewDidLoad() {
        super.viewDidLoad()
			
			
			
			let fetchRequest: NSFetchRequest<Favorite> = NSFetchRequest<Favorite>(entityName: "Favorite")
			
			do {
				favChurches = try coreDataStack.managedContext.fetch(fetchRequest)
			} catch {
				print("error getting fav churches")
			}
			
			for i in favChurches {
				PlacesAPI.lookupPlaceId(placesClient: placesClient, placeId: i.favoriteId!, address: nil, completionHandlerForChurch: { (church) in
					DispatchQueue.main.async {
						if i.isFavorite == true {
							self.favoriteChurches.append(church)
							
						} 
					}
					self.tableView.reloadData()
				})
				
			}
			


    }
 
	@IBAction func onCloseButtonPressed(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == Identifiers.favoriteToDetailSegue {
			let detailVC = segue.destination as! DetailViewController
			detailVC.currentChurch = currentChurch
		}
	}

}

extension FavoritesViewController: UITableViewDataSource, UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return favoriteChurches.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.favoritesCellIdentifier, for: indexPath) as! FavoritesCell
		let church = favoriteChurches[indexPath.row]
		cell.configureCell(church: church)
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let church = favoriteChurches[indexPath.row]
		currentChurch = church
		performSegue(withIdentifier: Identifiers.favoriteToDetailSegue, sender: self)
		print("CurrentChurch \(currentChurch)")
	}
}
