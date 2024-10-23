//
//  FRRatingViewModel.swift
//  Face_Rater_App
//
//  Created by Rashad Abdul-Salam on 10/6/24.
//

import Foundation
import Vision
import UIKit

typealias FRAlertTuple = (showAlert: Bool, message: String)

class FRRatingViewModel : ObservableObject {
    
    @Published var hotNotScore: Double?
    @Published var labScore: Double?
    @Published var compositeScore: Double?
    @Published var showScore = false
    @Published var faceDetected = false
    @Published var errorAlert: FRAlertTuple = (showAlert: false, message: "")
    
    var hotNotModel: MLModel?
    var labModel: MLModel?
    
    init() {
        loadCoreMLModels()
    }
    
    
    
    
    // Function to process numerical data with the MatModel
//    func processWithMatModel(rating: Double, raters: Double) {
//        guard let hotNotMod = hotNotModel else { return }
//        
//        // Convert the input data into a format suitable for the CoreML model
//        let input = try! MLMultiArray(shape: [3], dataType: .double)
//        input[0] = NSNumber(value: 1)  // Image number placeholder
//        input[1] = NSNumber(value: rating)
//        input[2] = NSNumber(value: raters)
//        
//        // Perform the CoreML prediction
//        if let result = try? hotNotMod.prediction(from: AttractivenessInput() {
//            let attractivenessScore = result.featureValue(for: "output")?.doubleValue
//            print("Mat Model Attractiveness Score: \(attractivenessScore ?? 0.0)")
//        }
//    }
    
    // Example function to combine predictions from both models
    func predictAttractiveness(with image: UIImage) {
        detectFace(in: image)
//        processImageWithLabModel(image)  // Get result from lab model
//        processImageHotNotMod(image)  // Get result from hotNot model
    
        guard let lab = labScore, let hotNot = hotNotScore else {
            print("Cannot get Scores for Composite: \(#function)")
            return
        }
        // Combine both model results (this is just an example)
        // You could average the two scores, weight them, etc.
        compositeScore = (lab * 0.7) + (hotNot * 0.3)
    }
}

// MARK: Private

private extension FRRatingViewModel {
    
    func loadCoreMLModels() {
        do {
            // Load both models
            hotNotModel = try Attractiveness(configuration: MLModelConfiguration()).model
            labModel = try Chinese_Attractiveness_Model(configuration: MLModelConfiguration()).model
        } catch {
            print("Failed to load models: \(error)")
        }
    }
    
    func detectFace(in image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        
        let request = VNDetectFaceRectanglesRequest { [weak self] (request, error) in
            guard let self = self, let results = request.results as? [VNFaceObservation], results.count > 0 else {
                DispatchQueue.main.async {
                    // No face detected
                    self?.faceDetected = false
                    self?.errorAlert = (true, "No Face Detected. Ensure you are providing a photo of a human face.")
                }
                return
            }
            
            DispatchQueue.main.async {
                if results.count == 1 {
                    // If only ONE face is detected, proceed to predict attractiveness
                    self.faceDetected = true
                    self.processImageHotNotMod(image)
                } else {
                    // Multiple faces detected--throw an error
                    self.faceDetected = false
                    self.errorAlert = (true, "Multiple faces detected. Ensure you are only providing a single human face.")
                }
            }
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                self.errorAlert = (true,"Error detecting faces: \(error)")
            }
        }
    }
    
    // Function to process a selfie image with the RatingsModel
    func processImageWithLabModel(_ image: UIImage) {
        guard let labMod = labModel else { return }
        
        // Convert the UIImage to a format suitable for the CoreML model
        let modelRequest = VNCoreMLRequest(model: try! VNCoreMLModel(for: labMod)) { [weak self] request, error in
            
            guard let self = self else {
                self?.errorAlert = (true,"Could not retrieve 'self' from callback \(#function)" )
                return
            }
            
            if let results = request.results as? [VNCoreMLFeatureValueObservation],
               let score = results.first?.featureValue.multiArrayValue?[0] {
                // Handle the attractiveness score from the ratings model
                print("Ratings Model Attractiveness Score: \(score)")
                self.labScore = Double(truncating: score)
            }
        }
        
        // Convert the image to CIImage
        let ciImage = CIImage(image: image)
        
        // Use a Vision handler to perform the request
        let handler = VNImageRequestHandler(ciImage: ciImage!, options: [:])
        try? handler.perform([modelRequest])
    }
    
    // Predict attractiveness using the CoreML model
    func processImageHotNotMod(_ image: UIImage) {
        // Convert UIImage to CIImage
        guard let ciImage = CIImage(image: image) else { return }

        // Load the CoreML model
        guard let model = try? VNCoreMLModel(for: Attractiveness().model) else {
            errorAlert = (true,"Error loading CoreML model")
            return
        }

        // Create a request for the model
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            
            guard let self = self else {
                self?.errorAlert = (true,"Could not retrieve 'self' from callback \(#function)" )
                return
            }
            
            if let results = request.results as? [VNCoreMLFeatureValueObservation],
               let prediction = results.first?.featureValue.multiArrayValue?[0] {
                DispatchQueue.main.async {
                    self.hotNotScore = Double(truncating: prediction)
                    self.showScore = false // Reset animation
                }
            }
        }

        // Perform the request
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        DispatchQueue.global().async {
            try? handler.perform([request])
        }
    }
    
}
