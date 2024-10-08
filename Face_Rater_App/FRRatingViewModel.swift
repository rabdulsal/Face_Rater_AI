//
//  FRRatingViewModel.swift
//  Face_Rater_App
//
//  Created by Rashad Abdul-Salam on 10/6/24.
//

import Foundation
import Vision
import UIKit

class FRRatingViewModel : ObservableObject {
    
    @Published var attractivenessScore: Double?
    var matModel: MLModel?
    var ratingsModel: MLModel?
    
    func loadCoreMLModels() {
//        do {
//            // Load both models
//            matModel = try Attractiveness_MatModel(configuration: MLModelConfiguration()).model
//            ratingsModel = try Attractiveness_RatingsModel(configuration: MLModelConfiguration()).model
//        } catch {
//            print("Failed to load models: \(error)")
//        }
    }
    
    // Function to process a selfie image with the RatingsModel
    func processImageWithRatingsModel(_ image: UIImage) {
        guard let ratingsModel = ratingsModel else { return }
        
        // Convert the UIImage to a format suitable for the CoreML model
        let modelRequest = VNCoreMLRequest(model: try! VNCoreMLModel(for: ratingsModel)) { request, error in
            if let results = request.results as? [VNCoreMLFeatureValueObservation],
               let score = results.first?.featureValue.multiArrayValue?[0] {
                // Handle the attractiveness score from the ratings model
                print("Ratings Model Attractiveness Score: \(score)")
            }
        }
        
        // Convert the image to CIImage
        let ciImage = CIImage(image: image)
        
        // Use a Vision handler to perform the request
        let handler = VNImageRequestHandler(ciImage: ciImage!, options: [:])
        try? handler.perform([modelRequest])
    }
    
    // Function to process numerical data with the MatModel
    func processWithMatModel(rating: Double, raters: Double) {
        guard let matModel = matModel else { return }
        
        // Convert the input data into a format suitable for the CoreML model
        let input = try! MLMultiArray(shape: [3], dataType: .double)
        input[0] = NSNumber(value: 1)  // Image number placeholder
        input[1] = NSNumber(value: rating)
        input[2] = NSNumber(value: raters)
        
        // Perform the CoreML prediction
//        if let result = try? matModel.prediction(from: Attractiveness_MatModelInput(input: input)) {
//            let attractivenessScore = result.featureValue(for: "output")?.doubleValue
//            print("Mat Model Attractiveness Score: \(attractivenessScore ?? 0.0)")
//        }
    }
    
    // Example function to combine predictions from both models
    func combineModelPredictions(image: UIImage, rating: Double, raters: Double) {
        processImageWithRatingsModel(image)  // Get result from ratings model
        processWithMatModel(rating: rating, raters: raters)  // Get result from mat model
        
        // Combine both model results (this is just an example)
        // You could average the two scores, weight them, etc.
        // let finalScore = (ratingsModelScore * 0.7) + (matModelScore * 0.3)
    }
}
