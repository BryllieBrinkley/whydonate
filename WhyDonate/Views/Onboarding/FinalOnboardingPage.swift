//
//  FinalOnboardingPage.swift
//  WhyDonate
//
//  Created by Jibryll Brinkley on 7/30/25.
//

import SwiftUI

struct FinalOnboardingPage: View {
    var onFinish: () -> Void

    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "star.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.blue)

            Text("Get Started")
                .font(.title)
                .bold()

            Text("You're ready to explore verified charities and start making an impact.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: {
                onFinish()
            }) {
                Text("Start Exploring")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Spacer()
        }
        .padding()
    }
}

