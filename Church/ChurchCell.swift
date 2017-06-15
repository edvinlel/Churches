//
//  ChurchCell.swift
//  Church
//
//  Created by Edvin Lellhame on 6/7/17.
//  Copyright © 2017 Edvin Lellhame. All rights reserved.
//

import UIKit

class ChurchCell: UITableViewCell {

	@IBOutlet weak var churchImageView: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var addressLabel: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	func configureCell(church: Church) {
		nameLabel.text = church.name
		addressLabel.text = church.address
		if let profileImage = church.profileImage {
			DispatchQueue.main.async(execute: {
				//print("---\(profileImage)")
				self.churchImageView.image = profileImage
			})
			
		} else {
			churchImageView.image = UIImage(named: "placeholder")
		}
		
		//print("placeId: \(church.placeId) name: \(church.name) address: \(church.address) fullAddress: \(church.fullAddress) website: \(church.website) phoneNumber: \(church.phoneNumber), profileImage: \(church.profileImage)")
	}

}
