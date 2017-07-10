//
//  ChurchCell.swift
//  Church
//
//  Created by Edvin Lellhame on 6/7/17.
//  Copyright © 2017 Edvin Lellhame. All rights reserved.
//

import UIKit

protocol ChurchCellDelegate {
	func churchCell(_ cell: UITableViewCell, button: UIButton)
}

class ChurchCell: UITableViewCell {

	@IBOutlet weak var churchImageView: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var addressLabel: UILabel!
	@IBOutlet weak var starButton: UIButton!
	
	var delegate: ChurchCellDelegate?
	
 
	@IBAction func handleButtonPressed(sender: UIButton) {
		delegate?.churchCell(self, button: sender)
	}
	
	func configureCell(church: Church) {
		nameLabel.text = church.name
		addressLabel.text = church.address
		if let profileImage = church.profileImage {
			DispatchQueue.main.async(execute: {
				self.churchImageView.image = profileImage
			})
			
		} else {
			churchImageView.image = UIImage(named: "placeholder")
		}
		
		if church.isFavorite {
			starButton.setImage(UIImage(named: "filled_star"), for: .normal)
			
		} else {
			starButton.setImage(UIImage(named: "star"), for: .normal)
		}
	}

}
