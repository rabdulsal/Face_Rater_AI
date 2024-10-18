//
//  ContentView.swift
//  Face_Rater_App
//
//  Created by Rashad Abdul-Salam on 10/5/24.
//

import SwiftUI
import CoreML




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

struct ContentView: View {
    @StateObject var faceRatingVM = FRRatingViewModel()
    @State private var image: UIImage?
    @State private var showingImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera

    var body: some View {
        
        ZStack(alignment: .topTrailing) {
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
                
                HStack(spacing: 30) {
                    // Button to take a selfie
                    Button(action: {
                        sourceType = .camera
                        showingImagePicker = true
                    }) {
                        //                    Text("Take a Selfie")
                        //                        .font(.headline)
                        //                        .padding()
                        //                        .background(Color.blue)
                        //                        .foregroundColor(.white)
                        //                        .cornerRadius(10)
                        Image(systemName: "camera.circle")
                            .resizable()
                            .frame(width: 100, height: 100)
                    }
                    .buttonStyle(PlainButtonStyle())
                    //                .padding()
                    
                    // Button to pick an image from the photo library
                    Button(action: {
                        sourceType = .photoLibrary
                        showingImagePicker = true
                    }) {
                        //                    Text("Select from Photo Library")
                        //                        .font(.headline)
                        //                        .padding()
                        //                        .background(Color.green)
                        //                        .foregroundColor(.white)
                        //                        .cornerRadius(10)
                        Image(systemName: "photo.circle")
                            .resizable()
                            .frame(width: 100, height: 100)
                    }
                    .buttonStyle(PlainButtonStyle())
                    //                .padding()
                }
                
            }
            
            // Show the predicted score with animation
            if let score = faceRatingVM.hotNotScore {
                //                Text("Attractiveness Score: \(String(format: "%.2f", score))")
                //                    .font(.largeTitle)
                //                    .fontWeight(.bold)
                //                    .opacity(showScore ? 1 : 0) // Animate opacity
                //                    .onAppear {
                //                        withAnimation(.easeIn(duration: 1.0)) {
                //                            showScore = true
                //                        }
                //                    }
                //                    .padding()
                FRStampedScoreView(number: Int(score))
                    .onAppear {
                        withAnimation(.easeIn(duration: 1.0)) {
                            faceRatingVM.showScore = true
                        }
                    }
//                FRCrosshairNumberView(number: Int(score))
//                    .offset(x: 50, y: -50)
            }
        }
        .sheet(isPresented: $showingImagePicker, onDismiss: processImage) {
            ImagePicker(image: $image, isPresented: $showingImagePicker, sourceType: sourceType)
        }
        .alert("ERROR!", isPresented: $faceRatingVM.errorAlert.showAlert) {
            Button(role: .cancel) {} label: {
                Text("OK")
            }
            
        } message: {
            Text(faceRatingVM.errorAlert.message)
        }
    }

    /// Function to process the image and predict attractiveness
    private func processImage() {
        guard let image = image else { return }
        faceRatingVM.predictAttractiveness(with: image)
    }
}

#Preview {
    ContentView(faceRatingVM: FRRatingViewModel())
}
