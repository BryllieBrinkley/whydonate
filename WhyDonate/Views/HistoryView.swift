import SwiftUI

struct HistoryView: View {
    var body: some View {
        CompatibleNavigationStack {
            Text("Your past donations will show here.")
                .navigationTitle("History")
        }
    }
}
