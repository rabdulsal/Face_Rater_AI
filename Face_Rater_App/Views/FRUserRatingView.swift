//
//  FRUserRatingView.swift
//  Face_Rater_App
//
//  Created by Rashad Abdul-Salam on 11/2/24.
//

import SwiftUI

struct FRUserRatingView: View {
    
    @Environment(\.dismiss) var dismiss
    
    var image: UIImage?
    
    var body: some View {
            
            
        VStack {
            
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Image("hot_not_bot_logo")
                    .resizable()
                    .scaledToFit()
            }
            
            FRRatingSlider()
            
            Button(action: {
                let _ = print("Save Pressed!")
                dismiss()
            }, label: {
                Text("Save")
                    .bold()
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .background(.orange)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            })
            .padding(EdgeInsets(top: 20, leading: 24, bottom: 0, trailing: 24))
            
            Spacer()
        }
            
            
    }
}

#Preview {
    FRUserRatingView()
}
