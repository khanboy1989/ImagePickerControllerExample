//
//  ViewController.swift
//  ImagePickerControlerExample
//
//  Created by Serhan Khan on 06/04/2020.
//  Copyright © 2020 Serhan Khan. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet weak var cameraView: UIView!
    private lazy var imagePickerController: UIImagePickerController = {
        let imagePickers = UIImagePickerController()
        if UIImagePickerController.isCameraDeviceAvailable(.rear) {
            imagePickers.delegate = self
            imagePickers.sourceType = UIImagePickerController.SourceType.camera
            imagePickers.view.frame = cameraView.bounds
            imagePickers.allowsEditing = false
            imagePickers.showsCameraControls = false
        }
        return imagePickers
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addCameraInView()
        // Do any additional setup after loading the view.
    }
    
    private func addCameraInView(){
        // Add the imageviewcontroller to UIView as a subview
        self.cameraView.addSubview((imagePickerController.view))
    }
}

