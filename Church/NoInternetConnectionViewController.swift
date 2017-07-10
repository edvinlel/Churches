//
//  NoInternetConnectionViewController.swift
//  Church
//
//  Created by Edvin Lellhame on 6/24/17.
//  Copyright © 2017 Edvin Lellhame. All rights reserved.
//

import UIKit
import ReachabilitySwift




class NoInternetConnectionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

			
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		ReachabilityManager.shared.addListener(listener: self)
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		
		ReachabilityManager.shared.removeListener(listener: self)
	}

	@IBAction func onTryAgainButtonPressed(_ sender: UIButton) {
	}
	

}

extension NoInternetConnectionViewController: NetworkStatusListener {
	func networkStatusDidChange(status: Reachability.NetworkStatus) {
		switch status {
		case .notReachable:
			debugPrint("NoInternetViewController: Network became unreachable")
		case .reachableViaWiFi:
			debugPrint("NoInternetViewController: Network available through wifi")
			dismiss(animated: true, completion: nil)
		case .reachableViaWWAN:
			debugPrint("NoInternetViewController: Network available through cellular data")
			dismiss(animated: true, completion: nil)
		}
		
		let haveNetwork = !(status == .notReachable)
		
		if !haveNetwork {
			
		}
	}
}
