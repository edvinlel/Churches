//
//  ImagePresentedViewController.swift
//  Church
//
//  Created by Edvin Lellhame on 6/16/17.
//  Copyright © 2017 Edvin Lellhame. All rights reserved.
//

import UIKit

class ImagePresentedViewController: UIViewController {
	
	@IBOutlet weak var imageView: UIImageView!
	
	var selectedImage: UIImage!

	override func viewDidLoad() {
		super.viewDidLoad()
		
		imageView.image = selectedImage
		
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissView))
		view.addGestureRecognizer(tapGesture)
	}
	
	@objc func dismissView() {
		dismiss(animated: true, completion: nil)
	}
    
	@IBAction func onDismissButtonPressed(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
	
	
	
	

}
