import SwiftUI

struct CausesYouCareAboutSection: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Causes You Care About")
                .font(.headline)
                .padding(.horizontal)

            VStack(alignment: .leading, spacing: 8) {
                Text("🌿 Environment: 3 recommended charities")
                Text("❤️ Health: 2 recommended charities")
                Text("🐾 Animal Welfare: 1 recommended charity")
            }
            .padding(.horizontal)
            .font(.body)
        }
    }
}
