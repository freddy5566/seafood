//
//  ViewController.swift
//  SeaFood
//
//  Created by Jamfly on 2018/5/27.
//  Copyright © 2018 Jamfly. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // setup navigation stuff
        let camera = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(cameraPressed))
        navigationItem.rightBarButtonItem = camera
        
        // setup imagepicker
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        
        // anchor view
        view.addSubview(imageView)
        imageView.ancher(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        
    }
    
    // MARK: imagepicker
    
    private let imagePicker = UIImagePickerController()
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let userPickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return }
       
        imageView.image = userPickedImage
        guard let ciImage = CIImage(image: userPickedImage) else {
            fatalError("Could not convert to CIImage")
        }
        
        detect(image: ciImage)
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    private func detect(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreML Model Failed")
            
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image")
            }
            
            guard let firstResult = results.first else { return }
            if firstResult.identifier.contains("hotdog") {
                self.title = "HotDog!"
            } else {
                self.title = "Not Hotdog!"
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
        
        
    }

    @objc func cameraPressed() {
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: view
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    

}

