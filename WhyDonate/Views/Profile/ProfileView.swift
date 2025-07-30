import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray)

                Text("Your Name")
                    .font(.title2)
                    .bold()

                Button("Log Out") {
                    // Add logout logic
                }
                .foregroundColor(.red)
            }
            .padding()
            .navigationTitle("Profile")
        }
    }
}
