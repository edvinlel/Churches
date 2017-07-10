//
//  Networking.swift
//  Church
//
//  Created by Edvin Lellhame on 6/24/17.
//  Copyright © 2017 Edvin Lellhame. All rights reserved.
//

import Foundation
import Alamofire

protocol NetworkProtocol {
	func request(completion: @escaping (NetworkResponse) -> Void)
}

enum NetworkResponse {
	case success(response: AnyObject)
	case error(error: String)
}

enum Network: NetworkProtocol {
	case get(url: String)
	
	func request(completion: @escaping (NetworkResponse) -> Void) {
		switch self {
		case .get(let url):
			Alamofire.request(url).responseJSON { (response) in
				guard let json = response.result.value as? [String: Any] else {
					completion(.error(error: "Error getting data from server \(String(describing: response.error?.localizedDescription))"))
					return
				}
				
				completion(.success(response: json as AnyObject))
			}
		}
	}
}
