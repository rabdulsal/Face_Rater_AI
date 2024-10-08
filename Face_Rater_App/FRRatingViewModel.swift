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
    func predictAttractiveness(image: UIImage) {
        guard let model = try? VNCoreMLModel(for: Attractiveness().model) else {
            fatalError("Could not load model")
        }
        
        let request = VNCoreMLRequest(model: model) { [weak self] (request, error) in
            guard
                let self = self,
                let results = request.results as? [VNCoreMLFeatureValueObservation],
                let score = results.first?.featureValue.multiArrayValue?[0] else {
                fatalError("Could not process image")
            }
            print("Predicted Attractiveness Score: \(score)")
            attractivenessScore = Double(truncating: score)
            
        }
        
        guard let ciImage = CIImage(image: image) else {
            fatalError("Unable to create CIImage from UIImage")
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        try? handler.perform([request])
    }
}
