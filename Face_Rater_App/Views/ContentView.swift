//
//  ContentView.swift
//  Face_Rater_App
//
//  Created by Rashad Abdul-Salam on 10/5/24.
//

import SwiftUI
import CoreML

struct ContentView: View {
    @StateObject var faceRatingVM = FRRatingViewModel()
    @State private var image: UIImage?
    @State private var showingImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    @State private var showRatingView = false

    var body: some View {
        
        NavigationStack {
            ZStack(alignment: .topLeading) {
                ZStack(alignment: .topTrailing) {
                    VStack {
                        // Show the selected image or a placeholder
                        
                        if let image = image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                            //                        .frame(width: 300, height: 300)
                                .frame(maxWidth: .infinity)
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
                                Image(systemName: "photo.circle")
                                    .resizable()
                                    .frame(width: 100, height: 100)
                            }
                            .buttonStyle(PlainButtonStyle())
                            //                .padding()
                        }
                        .padding(.top, 20)
                        
                        if let _ = image {
                            Button(action: {
                                showRatingView.toggle()
                            }, label: {
                                Text("You Rate")
                                    .padding(.horizontal)
                                    .bold()
                                    .frame(height: 50)
                                    .frame(maxWidth: .infinity)
                                    .background(.orange)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                    
                            })
                            .padding(EdgeInsets(top: 20, leading: 24, bottom: 0, trailing: 24))
                        }
                        
                    }
                    
                    // Show the predicted score with animation
                    if let score = faceRatingVM.hotNotScore {
                        
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
                
                
            }
            .sheet(isPresented: $showingImagePicker, onDismiss: processImage) {
                ImagePicker(image: $image, isPresented: $showingImagePicker, sourceType: sourceType)
            }
            .sheet(isPresented: $showRatingView, content: {
                FRUserRatingView(image: image)
            })
            .alert("ERROR!", isPresented: $faceRatingVM.errorAlert.showAlert) {
                Button(role: .cancel) {} label: {
                    Text("OK")
                }
                
            } message: {
                Text(faceRatingVM.errorAlert.message)
            }
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
