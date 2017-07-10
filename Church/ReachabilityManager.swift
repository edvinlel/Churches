//
//  ReachabilityManager.swift
//  Church
//
//  Created by Edvin Lellhame on 7/1/17.
//  Copyright © 2017 Edvin Lellhame. All rights reserved.
//

import Foundation
import ReachabilitySwift


protocol NetworkStatusListener: class {
	func networkStatusDidChange(status: Reachability.NetworkStatus)
}

class ReachabilityManager: NSObject {
	/// Shared instance
	static let shared = ReachabilityManager()
	
	/// Boolean to track network reachability
	var isNetworkAvailable: Bool {
		return reachabilityStatus != .notReachable
	}
	
	/// Tracks current Network Status 
	/// .notReachable
	/// .reachableViaWiFi
	/// .reachableViaWWAN
	var reachabilityStatus: Reachability.NetworkStatus = .notReachable
	
	/// Reachability instance for Network status monitoring
	let reachability = Reachability()!
	
	/// Array of delegates which are interested to listen to network status change
	var listeners = [NetworkStatusListener]()
	
	/// Called whenever there is a change in NetworkReachability Status
	///
	/// - parameter notification: Notification with the Reachability instance
	func reachabilityChanged(notification: Notification) {
		let reachability = notification.object as! Reachability
		
		switch reachability.currentReachabilityStatus {
		case .notReachable:
			debugPrint("Reachability Network became unreachable")
		case .reachableViaWiFi:
			debugPrint("Reachability Network reachable through WiFi")
		case .reachableViaWWAN:
			debugPrint("Reachability Network reachable through Cellular Data")
		}
		
		for listener in listeners {
			listener.networkStatusDidChange(status: reachability.currentReachabilityStatus)
		}
	}
	
	/// Starts monitoring the network availability status
	func startMonitoring() {
		NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged), name: ReachabilityChangedNotification, object: reachability)
		do {
			try reachability.startNotifier()
		} catch {
				debugPrint("Could not start reachability notifier")
		}
		
	}
	
	/// Stop monitoring the network availabilty status
	func stopMonitoring() {
		reachability.stopNotifier()
		NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: reachability)
	}
	
	/// Adds a new listener to the listeners array
	//
	/// - parameter listener: a new listener to add
	func addListener(listener: NetworkStatusListener) {
		listeners.append(listener)
	}
	
	/// Removes a listener from the listeners array
	//
	/// = parameter listener: the listener to be removed
	func removeListener(listener: NetworkStatusListener) {
		listeners = listeners.filter{ $0 !== listener }
	}
}














