//
//  CustomImageFlowLayout.swift
//  Church
//
//  Created by Edvin Lellhame on 6/15/17.
//  Copyright © 2017 Edvin Lellhame. All rights reserved.
//

import UIKit

class CustomImageFlowLayout: UICollectionViewFlowLayout {
	override init() {
		super.init()
		setupLayout()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setupLayout()
	}
	
	func setupLayout() {
		minimumLineSpacing = 1
		minimumInteritemSpacing = 1
		scrollDirection = .vertical
	}
	
	override var itemSize: CGSize {
		set {}
		get {
			let numberOfColumns: CGFloat = 3
			let itemWidth = (self.collectionView!.frame.width - (numberOfColumns - 1)) / numberOfColumns

			return CGSize(width: itemWidth, height: itemWidth)
		}
	}
}
