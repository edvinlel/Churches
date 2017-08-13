//
//  FavoritesCell.swift
//  Church
//
//  Created by Edvin Lellhame on 8/12/17.
//  Copyright © 2017 Edvin Lellhame. All rights reserved.
//

import UIKit

class FavoritesCell: UITableViewCell {

	@IBOutlet weak var addressLabel: UILabel!
	@IBOutlet weak var nameLabel: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

	func configureCell(church: Church) {
		nameLabel.text = church.name
		addressLabel.text = church.fullAddress
	}

}
