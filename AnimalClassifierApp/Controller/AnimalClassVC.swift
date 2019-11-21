//
//  AnimalClassVC.swift
//  AnimalClassifierApp
//
//  Created by Denis Rakitin on 2019-10-18.
//  Copyright © 2019 Denis Rakitin. All rights reserved.
//

import UIKit
import CoreML
import Vision

class AnimalClassVC: UIViewController, UIImagePickerControllerDelegate,  UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var classificationLbl: UILabel!
    
    lazy var classificationRequest: VNCoreMLRequest = {
        do {
            let model = try VNCoreMLModel(for: AmimalCoreML_1().model)
            
            let request = VNCoreMLRequest(model: model) { (request, error) in
                self.processClassification(for: request, error: error)
            }
            
            request.imageCropAndScaleOption = .centerCrop
            return request
            
        } catch  {
            fatalError("Failed to load Vision ML model: \(error)")
        }
    }()
    
    func processClassification(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
        guard let classifications = request.results as? [VNClassificationObservation] else {
                self.classificationLbl.text = "Unable to classify image. \n\(error?.localizedDescription ?? "Error")"
                return
            }
            
            if classifications.isEmpty {
                self.classificationLbl.text = "Nothing recognized"
            } else {
                let topClassifications = classifications.prefix(2)
                let descriptions = topClassifications.map { classification in
                    return String(format: "%.2f", classification.confidence * 100) + "% - " + classification.identifier
                }
                
                self.classificationLbl.text = "Classifications: \n" + descriptions.joined(separator: "\n ")
            }
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func upadateClassifications(for image: UIImage) {
        classificationLbl.text = "Classifying..."
        
        guard let orientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue)), let ciImage = CIImage(image: image) else {
            displayError()
            return
        }
        
        DispatchQueue.global(qos: .userInteractive).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            do {
                try handler.perform([self.classificationRequest])
            } catch  {
                print("Failed to perform classification. \n\(error.localizedDescription)")
            }
        }

    }
    
    func displayError() {
        classificationLbl.text = "Something went wrong... \n Please try again"
    }
    
    @IBAction func cameraBtnWasPressed(_ sender: Any) {
        
    
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            presentPhotoPicker(sourceType: .photoLibrary)
            return
        }
        
        let photoSourcePicker = UIAlertController()
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default) { _ in
            self.presentPhotoPicker(sourceType: .camera)
        }
        
        let choosePhotoAction = UIAlertAction(title: "Choose Photo", style: .default) { _ in
            self.presentPhotoPicker(sourceType: .photoLibrary)
        }
        
        photoSourcePicker.addAction(takePhotoAction)
        photoSourcePicker.addAction(choosePhotoAction)
        photoSourcePicker.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(photoSourcePicker, animated: true, completion: nil)

    }
    
    func presentPhotoPicker (sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.sourceType = sourceType
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { fatalError("No image returned") }
        
        imageView.image = image
        
        upadateClassifications(for: image)
    }

}
