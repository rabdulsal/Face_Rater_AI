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
            .font(.system(size: 100, weight: .bold, design: .monospaced)) // Large, bold font
            .foregroundColor(.black)
            .padding(20)
            .background(
                Circle() // Circular background to mimic a stamp
                    .fill(Color.red.opacity(0.7))
                    .frame(width: 200, height: 200)
            )
            .overlay(
                Circle()
                    .stroke(Color.black, lineWidth: 10)
            )
            .shadow(color: Color.black.opacity(0.4), radius: 8, x: 4, y: 4) // Shadow for depth
            .rotationEffect(.degrees(-10)) // Slight rotation for realism
            .opacity(0.9) // Slight transparency
    }
}

#Preview {
    FRStampedScoreView(number: 7)
}
