//
//  FRStampedScoreView.swift
//  Face_Rater_App
//
//  Created by Rashad Abdul-Salam on 10/8/24.
//

import SwiftUI

struct FRStampedScoreView: View {
    
    var number: Int
    
    var body: some View {
        Text("\(number)")
            .font(.system(size: 60, weight: .bold, design: .monospaced)) // Large, bold font
            .foregroundColor(.black)
            .padding(20)
            .background(
                Circle() // Circular background to mimic a stamp
                    .fill(Color.red.opacity(0.8))
                    .frame(width: 120, height: 120)
            )
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 10)
            )
            .shadow(color: Color.black.opacity(0.4), radius: 8, x: 4, y: 4) // Shadow for depth
            .rotationEffect(.degrees(-10)) // Slight rotation for realism
            .opacity(0.9) // Slight transparency
    }
}

struct FRCrosshairNumberView: View {
    var number: Int
    var body: some View {
        ZStack {
            // Horizontal line for the crosshair
            Rectangle()
                .fill(Color.red)
                .frame(width: 200, height: 10)
            
            // Vertical line for the crosshair
            Rectangle()
                .fill(Color.red)
                .frame(width: 10, height: 200)
            
            Circle()
//                .fill(Color.clear)
                .stroke(Color.red, lineWidth: 10)
                .frame(width: 150, height: 150)
            
            Circle()
                .fill(Color.white)
//                .stroke(Color.red, lineWidth: 10)
                .frame(width: 100, height: 100)
            
            // Number in the center
            Text("\(number)")
                .font(.system(size: 60, weight: .bold, design: .monospaced))
                .foregroundColor(.red)
        }
        .rotationEffect(.degrees(-10)) // Slight rotation for realism
        .frame(width: 200, height: 200) // Set a fixed frame for the view
    }
}

#Preview {
//    FRStampedScoreView(number: 7)
    FRCrosshairNumberView(number: 7)
}
