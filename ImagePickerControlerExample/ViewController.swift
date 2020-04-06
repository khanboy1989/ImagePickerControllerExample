//
//  ViewController.swift
//  ImagePickerControlerExample
//
//  Created by Serhan Khan on 06/04/2020.
//  Copyright © 2020 Serhan Khan. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
   
    @IBOutlet weak var scanLayerView: UIView!{
        didSet{
            //Draw rectange borders around the scanlayer
            self.scanLayerView.strokeBorder()
            //Add radius to scan layer
            self.scanLayerView.layer.cornerRadius = 10
        }
    }
    
    @IBOutlet weak var cameraLayer: UIView! {
        didSet{
            self.cameraLayer.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        }
    }
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
    }
    
    private func addCameraLayerAndScanLayer(){
        // Draw a graphics with a mostly solid alpha channel
        // and a square of "clear" alpha in there.
        UIGraphicsBeginImageContext(self.cameraLayer.bounds.size)
        let cgContext = UIGraphicsGetCurrentContext()
        cgContext?.fill(self.cameraLayer.bounds)
        cgContext?.clear(CGRect(x:self.scanLayerView.frame.origin.x, y:self.scanLayerView.frame.origin.y, width: self.scanLayerView.bounds.width - 10, height: self.scanLayerView.bounds.height - 10 ))
        let maskImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Set the content of the mask view so that it uses our
        // alpha channel image
        let maskView = UIView(frame: self.cameraLayer.bounds)
        maskView.layer.contents = maskImage?.cgImage
        self.cameraLayer.mask = maskView
    }
    
    private func addCameraInView(){
        // Add the imageviewcontroller to UIView as a subview
        self.cameraView.addSubview((imagePickerController.view))
        self.addCameraLayerAndScanLayer()
    }
    
    @IBAction func takePhotoButtonTapped(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            self.imagePickerController.takePicture()
        } else{
            print("Error on taking picture")
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            let width = self.scanLayerView.bounds.width
            let height = self.scanLayerView.bounds.height
            self.fixOrientation(img: image, completion: { fixedImage -> Void in
                self.cropImage(image: fixedImage, to: CGFloat(width / height), completion: { image -> Void in
                    DispatchQueue.main.async {
                     let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "DetailViewController") as? ImagePreviewViewController
                        vc?.image = image
                        self.navigationController?.pushViewController(vc!, animated: true)
                    }
                })
            })
        }
    }
    
    
    func fixOrientation(img: UIImage, completion :@escaping (UIImage)-> ()) {
        DispatchQueue.global(qos: .background).async {
            if (img.imageOrientation == .up) {
                completion(img)
            }
            
            UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale)
            let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
            img.draw(in: rect)
            
            let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            
            completion(normalizedImage)
        }
    }
    
    func cropImage(image: UIImage, to aspectRatio: CGFloat,completion: @escaping (UIImage) -> ()) {
        DispatchQueue.global(qos: .background).async {
            
            let imageAspectRatio = image.size.height/image.size.width
            
            var newSize = image.size
            
            if imageAspectRatio > aspectRatio {
                newSize.height = image.size.width * aspectRatio
            } else if imageAspectRatio < aspectRatio {
                newSize.width = image.size.height / aspectRatio
            } else {
                completion (image)
            }
            
            let center = CGPoint(x: image.size.width/2, y: image.size.height/2)
            let origin = CGPoint(x: center.x - newSize.width/2, y: center.y - newSize.height/2)
            
            let cgCroppedImage = image.cgImage!.cropping(to: CGRect(origin: origin, size: CGSize(width: newSize.width, height: newSize.height)))!
            let croppedImage = UIImage(cgImage: cgCroppedImage, scale: image.scale, orientation: image.imageOrientation)
            
            completion(croppedImage)
        }
    }
    
}

extension UIView {
    
    func strokeBorder() {
        
        self.backgroundColor = .clear
        self.clipsToBounds = true
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = UIBezierPath(rect: self.bounds).cgPath
        self.layer.mask = maskLayer
        
        let line = NSNumber(value: Float(self.bounds.width  * 4))
        
        let borderLayer = CAShapeLayer()
        borderLayer.path = maskLayer.path
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = UIColor.white.cgColor
        borderLayer.lineDashPattern = [line]
        borderLayer.lineDashPhase = self.bounds.width / 4
        borderLayer.lineWidth = 10
        borderLayer.frame = self.bounds
        self.layer.addSublayer(borderLayer)
    }
}
