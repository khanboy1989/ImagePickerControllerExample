//
//  ImagePreviewViewController.swift
//  ImagePickerControlerExample
//
//  Created by Serhan Khan on 06/04/2020.
//  Copyright © 2020 Serhan Khan. All rights reserved.
//

import UIKit

class ImagePreviewViewController: UIViewController {

    @IBOutlet weak var imagePrevieImageView: UIImageView!
    
    public var image:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let imag = self.image {
            self.imagePrevieImageView?.image = imag
        }
    }

}
