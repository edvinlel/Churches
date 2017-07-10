//
//  ChurchTableView+Extension.swift
//  Church
//
//  Created by Edvin Lellhame on 6/18/17.
//  Copyright © 2017 Edvin Lellhame. All rights reserved.
//

import Foundation
import UIKit


// Enum for the section of two different arrays for tableView
enum Section: Int {
	case favorites
	case nonFavorites
	case numberOfSections
}

extension ChurchTableViewController: UITableViewDelegate, UITableViewDataSource {
	// Remove the item from array at the indexPath
	func remove(at indexPath: IndexPath) {
		guard let section = Section(rawValue: indexPath.section) else { return }
		
		switch section {
		case .favorites:
			favoriteChurches.remove(at: indexPath.row)
		case .nonFavorites:
			nonFavoriteChurches.remove(at: indexPath.row)
		default:
			break
		}
	}
	
	func set(_ church: Church, at indexPath: IndexPath) {
		guard let section = Section(rawValue: indexPath.section) else { return }
		
		switch section {
		case .favorites:
			favoriteChurches[indexPath.row] = church
		case .nonFavorites:
			nonFavoriteChurches[indexPath.row] = church
		default:
			break
		}
	}
	
	// return church at indexPath
	func church(at indexPath: IndexPath) -> Church? {
		guard let section = Section(rawValue: indexPath.section) else { return nil }
		
		switch section {
		case .favorites:
			return favoriteChurches[indexPath.row]
		case .nonFavorites:
			return nonFavoriteChurches[indexPath.row]
		default:
			return nil
		}
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return Section.numberOfSections.rawValue
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let sectionIndex = Section(rawValue: section) else { return 0	}
		
		switch sectionIndex {
		case .favorites:
			return favoriteChurches.count
		case .nonFavorites:
			return nonFavoriteChurches.count
		default:
			return 0
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.churchCellIdentifier, for: indexPath) as! ChurchCell
		
		if var church = church(at: indexPath) {
			church.isFavorite = CoreDataStack.stack.isChurchFavorited(id: church.placeId)
			cell.configureCell(church: church)
		}
	
		cell.delegate = self
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let church = church(at: indexPath) {
			currentChurchSelected = church
			performSegue(withIdentifier: Identifiers.detailSegue, sender: self)
		}
	}
}

extension ChurchTableViewController: ChurchCellDelegate {
	// used a ChurchCell delegate to handle the favorites star button pressed
	func churchCell(_ cell: UITableViewCell, button: UIButton) {
		guard let indexPath = tableView.indexPath(for: cell) else {
			return
		}
		
		if var church = church(at: indexPath) {
			let isFavorite = !coreDataStack.isChurchFavorited(id: church.placeId)
			coreDataStack.markChurchFavorited(id: church.placeId, favorite: isFavorite)
			remove(at: indexPath)
			if !isFavorite {
				button.setImage(UIImage(named: ImageNames.star), for: .normal)
				church.isFavorite = false
				coreDataStack.saveContext()
			} else {
				button.setImage(UIImage(named: ImageNames.filledStar), for: .normal)
				church.isFavorite = true
			}
			self.appendChurch(church)
			self.tableView.reloadData()
		}
	}
}

