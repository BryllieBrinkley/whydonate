import SwiftUI

struct OnboardingPage: View {
    let title: String
    let description: String
    let systemImageName: String

    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: systemImageName)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.blue)

            Text(title)
                .font(.title)
                .bold()

            Text(description)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()
        }
        .padding()
    }
}
