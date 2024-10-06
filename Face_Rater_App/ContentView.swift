//
//  ContentView.swift
//  Face_Rater_App
//
//  Created by Rashad Abdul-Salam on 10/5/24.
//

import SwiftUI
import CoreML
import Vision

import UIKit

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var isPresented: Bool
    var sourceType: UIImagePickerController.SourceType

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker

        init(parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.isPresented = false
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType  // Set the source type (camera or photo library)
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {}
}

class FRAttractivenessCalucator {
    func predictAttractiveness(image: UIImage) {
        guard let model = try? VNCoreMLModel(for: Attractiveness().model) else {
            fatalError("Could not load model")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNCoreMLFeatureValueObservation],
                  let attractivenessScore = results.first?.featureValue.multiArrayValue?[0] else {
                fatalError("Could not process image")
            }
            
            print("Predicted Attractiveness Score: \(attractivenessScore)")
        }
        
        guard let ciImage = CIImage(image: image) else {
            fatalError("Unable to create CIImage from UIImage")
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        try? handler.perform([request])
    }
}

struct ContentView: View {
    @State private var image: UIImage?
    @State private var showingImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    @State private var attractivenessScore: Double?
    @State private var showScore = false

    var body: some View {
        VStack {
            // Show the selected image or a placeholder
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .foregroundColor(.gray)
            }

            // Button to take a selfie
            Button(action: {
                sourceType = .camera
                showingImagePicker = true
            }) {
                Text("Take a Selfie")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()

            // Button to pick an image from the photo library
            Button(action: {
                sourceType = .photoLibrary
                showingImagePicker = true
            }) {
                Text("Select from Photo Library")
                    .font(.headline)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()

            // Show the predicted score with animation
            if let score = attractivenessScore {
                Text("Attractiveness Score: \(String(format: "%.2f", score))")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .opacity(showScore ? 1 : 0) // Animate opacity
                    .onAppear {
                        withAnimation(.easeIn(duration: 1.0)) {
                            showScore = true
                        }
                    }
                    .padding()
            }
        }
        .sheet(isPresented: $showingImagePicker, onDismiss: processImage) {
            ImagePicker(image: $image, isPresented: $showingImagePicker, sourceType: sourceType)
        }
    }

    // Function to process the image and predict attractiveness
    func processImage() {
        guard let image = image else { return }
        predictAttractiveness(image: image)
    }

    // Predict attractiveness using the CoreML model
    func predictAttractiveness(image: UIImage) {
        // Convert UIImage to CIImage
        guard let ciImage = CIImage(image: image) else { return }

        // Load the CoreML model
        guard let model = try? VNCoreMLModel(for: Attractiveness().model) else {
            print("Error loading CoreML model")
            return
        }

        // Create a request for the model
        let request = VNCoreMLRequest(model: model) { request, error in
            if let results = request.results as? [VNCoreMLFeatureValueObservation],
               let prediction = results.first?.featureValue.multiArrayValue?[0] {
                DispatchQueue.main.async {
                    self.attractivenessScore = Double(truncating: prediction)
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
