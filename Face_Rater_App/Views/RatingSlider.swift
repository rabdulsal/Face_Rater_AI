//
//  RatingSlider.swift
//  Face_Rater_App
//
//  Created by Rashad Abdul-Salam on 11/2/24.
//

import SwiftUI

struct RatingSlider: View {
    @State private var rating: Double = 5.0  // Default starting point

        var body: some View {
            VStack {
                
                HStack(spacing: 10) {
                    Text("Rate Image")
                        .font(.headline)
                        .bold()
                        .foregroundStyle(.white)
                    
                    Text(String(format: "%.1f", rating))
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.orange)  // Custom color to highlight rating
                    
                }
                .padding(.bottom, -10)
                
                Slider(value: $rating, in: 1...10, step: 0.5)
                    .accentColor(.orange)  // Custom color for the slider


                HStack {
                    Text("1.0")
                    Spacer()
                    Text("10.0")
                }
                .font(.footnote)
                .bold()
                .foregroundStyle(.white)
                
            }
            .padding(.horizontal, 10)
            .background(.black.opacity(0.2))
            .frame(height: 20)
        }
}

#Preview {
    RatingSlider()
}
