//
//  VerifyURL.swift
//  Church
//
//  Created by Edvin Lellhame on 6/15/17.
//  Copyright © 2017 Edvin Lellhame. All rights reserved.
//

import Foundation
import UIKit

struct VerifyURL {
	// Verify the url before sending to web view
	static func verifyURL(address: String?) -> Bool {
		// Check address for nil
		if let address = address {
			if let url = URL(string: address) {
				// Check if address can be opened
				return UIApplication.shared.canOpenURL(url)
			}
		}
		return false
	}
}
