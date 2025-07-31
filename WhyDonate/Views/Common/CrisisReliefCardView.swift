import SwiftUI

struct CrisisReliefCardView: View {
    let title: String
    let description: String
    let imageName: String
    let urgencyLevel: UrgencyLevel
    let donationGoal: Double?
    let amountRaised: Double?
    
    enum UrgencyLevel: CaseIterable {
        case critical, high, medium
        
        var color: Color {
            switch self {
            case .critical: return .red
            case .high: return .orange
            case .medium: return .yellow
            }
        }
        
        var text: String {
            switch self {
            case .critical: return "CRITICAL"
            case .high: return "URGENT"
            case .medium: return "NEEDED"
            }
        }
    }
    
    private var progress: Double {
        guard let goal = donationGoal, let raised = amountRaised, goal > 0 else { return 0 }
        return min(raised / goal, 1.0)
    }
    
    // Default initializer for backward compatibility
    init(title: String, description: String, imageName: String = "exclamationmark.triangle.fill", urgencyLevel: UrgencyLevel = .high, donationGoal: Double? = nil, amountRaised: Double? = nil) {
        self.title = title
        self.description = description
        self.imageName = imageName
        self.urgencyLevel = urgencyLevel
        self.donationGoal = donationGoal
        self.amountRaised = amountRaised
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with urgency indicator
            HStack {
                Image(systemName: imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32, height: 32)
                    .foregroundColor(urgencyLevel.color)
                
                Spacer()
                
                Text(urgencyLevel.text)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(urgencyLevel.color)
                    )
            }
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Text(description)
                    .font(.subheadline)
                    .lineLimit(3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            // Progress section if goals exist
            if let goal = donationGoal, let raised = amountRaised {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Raised: $\(Int(raised).formatted())")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("Goal: $\(Int(goal).formatted())")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    ProgressView(value: progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: urgencyLevel.color))
                        .scaleEffect(y: 1.2)
                }
            }
            
            // Action button
            Button(action: {
                // Handle donation action
            }) {
                HStack {
                    Image(systemName: "heart.fill")
                        .font(.caption)
                    Text("Donate Now")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(urgencyLevel.color)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(16)
        .frame(width: 220, minHeight: 200)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: urgencyLevel.color.opacity(0.2), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(urgencyLevel.color.opacity(0.3), lineWidth: 2)
        )
        // Performance optimization: Stable identity
        .id("\(title)-\(urgencyLevel.text)")
        // Accessibility improvements
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(urgencyLevel.text): \(title). \(description)")
        .accessibilityHint("Crisis relief donation opportunity")
    }
}

// MARK: - Preview
#Preview {
    HStack {
        CrisisReliefCardView(
            title: "Wildfire Relief",
            description: "Support communities affected by devastating wildfires.",
            urgencyLevel: .critical,
            donationGoal: 100000,
            amountRaised: 65000
        )
        
        CrisisReliefCardView(
            title: "Flood Emergency Response",
            description: "Immediate aid for flood victims and recovery efforts.",
            imageName: "drop.fill",
            urgencyLevel: .high,
            donationGoal: 75000,
            amountRaised: 30000
        )
    }
    .padding()
}
