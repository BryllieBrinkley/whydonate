import SwiftUI

struct SuggestedByCauseSection: View {
    @ObservedObject var viewModel: CharityViewModel
    @State private var selectedCause: String? = nil
    
    private let causes = ["Health", "Animals", "Environment", "Education", "Children", "Emergency", "Community", "Housing"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Pick a Cause, We'll Suggest")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Discover charities by category")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            
            // Cause selection buttons
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(causes, id: \.self) { cause in
                        CauseButton(
                            cause: cause,
                            isSelected: selectedCause == cause,
                            action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedCause = selectedCause == cause ? nil : cause
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
            .conditionalScrollClipDisabled()
            
            // Suggested charities based on selected cause
            if let selectedCause = selectedCause {
                let suggestedCharities = viewModel.getCharitiesByCategory(selectedCause)
                
                if !suggestedCharities.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Suggested \(selectedCause) Charities")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text("\(suggestedCharities.count) found")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 16) {
                                ForEach(suggestedCharities.prefix(6)) { charity in
                                    NavigationLink(destination: CharityDetailView(charity: charity)) {
                                        CharityCardView(charity: charity)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal)
                        }
                        .conditionalScrollClipDisabled()
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                } else {
                    // Empty state
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        
                        Text("No \(selectedCause.lowercased()) charities found")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("Try selecting a different cause")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
                    .transition(.opacity)
                }
            }
        }
    }
}

// MARK: - Cause Button Component
struct CauseButton: View {
    let cause: String
    let isSelected: Bool
    let action: () -> Void
    
    private var causeIcon: String {
        switch cause {
        case "Health": return "heart.fill"
        case "Animals": return "pawprint.fill"
        case "Environment": return "leaf.fill"
        case "Education": return "book.fill"
        case "Children": return "figure.2.and.child.holdinghands"
        case "Emergency": return "exclamationmark.triangle.fill"
        case "Community": return "house.fill"
        case "Housing": return "hammer.fill"
        default: return "heart.fill"
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: causeIcon)
                    .font(.caption)
                
                Text(cause)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? .white : .blue)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? Color.blue : Color.blue.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.blue, lineWidth: isSelected ? 0 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

// MARK: - Preview
#Preview {
    SuggestedByCauseSection(viewModel: CharityViewModel.shared)
        .padding()
}
