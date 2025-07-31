import SwiftUI

struct SuggestedByCauseSection: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Pick a Cause, We'll Suggest")
                .font(.headline)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(["Health", "Animals", "Environment", "Education", "Children"], id: \.self) { cause in
                        Button(action: {
                            // Suggest charities by cause logic
                        }) {
                            Text(cause)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(20)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
