//
//  CoreDataStack.swift
//  Church
//
//  Created by Edvin Lellhame on 6/17/17.
//  Copyright © 2017 Edvin Lellhame. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
	private let modelName: String
	
	static let stack = CoreDataStack(modelName: "Church")
	
	init(modelName: String) {
		self.modelName = modelName
	}
	
	private lazy var storeContainer: NSPersistentContainer = {
		let container = NSPersistentContainer(name: self.modelName)
		container.loadPersistentStores { (_, error) in
			if let error = error as NSError? {
				print("Unresolved error \(error), \(error.userInfo)")
			}
		}
		return container
	}()
	
	lazy var managedContext: NSManagedObjectContext = {
		return self.storeContainer.viewContext
	}()
	
	func saveContext() {
		guard managedContext.hasChanges else { return }
		
		do {
			try managedContext.save()
		} catch let error as NSError {
			print("Unresolved error \(error), \(error.userInfo)")
		}
	}
	
	func markChurchFavorited(id: String, favorite: Bool) {
		let fetchRequest = NSFetchRequest<Favorite>(entityName: "Favorite")
		fetchRequest.predicate = NSPredicate(format: "favoriteId = %@", id)
		
		if let results = try? self.managedContext.fetch(fetchRequest), let found = results.first {
			found.isFavorite = favorite
		} else if favorite {
			let record = NSEntityDescription.insertNewObject(forEntityName: "Favorite", into: self.managedContext) as! Favorite
			record.favoriteId = id
			record.isFavorite = favorite
		}
		self.saveContext()
	}
	
	func isChurchFavorited(id: String) -> Bool {
		let fetchRequest = NSFetchRequest<Favorite>(entityName: "Favorite")
		fetchRequest.predicate = NSPredicate(format: "favoriteId = %@", id)

		if let results = try? self.managedContext.fetch(fetchRequest), let found = results.first {
			return found.isFavorite
		}
		return false
	}
}








