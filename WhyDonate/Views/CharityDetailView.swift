import SwiftUI

struct CharityDetailView: View {
    let charity: CharityModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingDonationSheet = false
    @State private var isBookmarked = false
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                // Hero section
                VStack(alignment: .leading, spacing: 16) {
                    // Charity icon and basic info
                    HStack(alignment: .top, spacing: 16) {
                        Image(systemName: charity.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .foregroundColor(.blue)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.blue.opacity(0.1))
                                    .frame(width: 100, height: 100)
                            )
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(charity.name)
                                .font(.title2)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.leading)
                            
                            Text(charity.category)
                                .font(.subheadline)
                                .foregroundColor(.blue)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color.blue.opacity(0.1))
                                )
                            
                            if charity.isUrgent {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.orange)
                                    Text("Urgent Need")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.orange)
                                }
                            }
                            
                            if let location = charity.location {
                                HStack {
                                    Image(systemName: "location.fill")
                                        .foregroundColor(.blue)
                                    Text(location)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            isBookmarked.toggle()
                        }) {
                            Image(systemName: isBookmarked ? "heart.fill" : "heart")
                                .font(.title2)
                                .foregroundColor(isBookmarked ? .red : .secondary)
                        }
                    }
                    
                    // Progress section
                    if let goal = charity.donationGoal, let raised = charity.amountRaised {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Fundraising Progress")
                                    .font(.headline)
                                Spacer()
                                Text("\(Int(charity.progress * 100))% Complete")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.blue)
                            }
                            
                            ProgressView(value: charity.progress)
                                .progressViewStyle(.tinted(.blue))
                                .scaleEffect(y: 2.0)
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("$\(Int(raised).formatted())")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                    Text("Raised")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing) {
                                    Text("$\(Int(goal).formatted())")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                    Text("Goal")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemGray6))
                        )
                    }
                }
                .padding(.horizontal)
                
                // Description section
                VStack(alignment: .leading, spacing: 12) {
                    Text("About This Charity")
                        .font(.headline)
                    
                    Text(charity.description)
                        .font(.body)
                        .lineSpacing(4)
                        .foregroundColor(.primary)
                    
                    if let website = charity.website {
                        Link(destination: URL(string: website)!) {
                            HStack {
                                Image(systemName: "globe")
                                Text("Visit Website")
                                Spacer()
                                Image(systemName: "arrow.up.right")
                            }
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .padding(.vertical, 8)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Impact section (placeholder for future implementation)
                VStack(alignment: .leading, spacing: 12) {
                    Text("Impact & Transparency")
                        .font(.headline)
                    
                    VStack(spacing: 12) {
                        ImpactMetricRow(icon: "checkmark.circle.fill", title: "Verified Charity", subtitle: "Meets all transparency standards")
                        ImpactMetricRow(icon: "star.fill", title: "4.8/5 Rating", subtitle: "Based on 1,247 donor reviews")
                        ImpactMetricRow(icon: "chart.line.uptrend.xyaxis", title: "Growing Impact", subtitle: "Served 15% more beneficiaries this year")
                    }
                }
                .padding(.horizontal)
                
                Spacer(minLength: 100) // Space for floating button
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Share") {
                    // Share functionality
                }
                .font(.subheadline)
            }
        }
        .overlay(alignment: .bottom) {
            // Floating donation button
            Button(action: {
                showingDonationSheet = true
            }) {
                HStack {
                    Image(systemName: "heart.fill")
                        .font(.title3)
                    Text("Donate Now")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.blue)
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                )
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .sheet(isPresented: $showingDonationSheet) {
            DonationSheet(charity: charity)
        }
    }
}

// MARK: - Impact Metric Row Component
struct ImpactMetricRow: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.green)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Donation Sheet (Placeholder)
struct DonationSheet: View {
    let charity: CharityModel
    @Environment(\.dismiss) private var dismiss
    @State private var donationAmount: String = ""
    
    private let suggestedAmounts = [25, 50, 100, 250]
    
    var body: some View {
        CompatibleNavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Support \(charity.name)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Your donation makes a real difference")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Suggested amounts
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(suggestedAmounts, id: \.self) { amount in
                        Button("$\(amount)") {
                            donationAmount = String(amount)
                        }
                        .font(.headline)
                        .foregroundColor(donationAmount == String(amount) ? .white : .blue)
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(donationAmount == String(amount) ? Color.blue : Color.blue.opacity(0.1))
                        )
                    }
                }
                
                // Custom amount input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Custom Amount")
                        .font(.headline)
                    
                    HStack {
                        Text("$")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        TextField("Enter amount", text: $donationAmount)
                            .font(.title2)
                            .keyboardType(.numberPad)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                }
                
                Spacer()
                
                // Donate button
                Button("Donate $\(donationAmount.isEmpty ? "0" : donationAmount)") {
                    // Handle donation
                    dismiss()
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(donationAmount.isEmpty ? Color.gray : Color.blue)
                )
                .disabled(donationAmount.isEmpty)
            }
            .padding()
            .navigationTitle("Make a Donation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    CompatibleNavigationStack {
        CharityDetailView(
            charity: CharityModel(
                name: "St. Jude Children's Research Hospital",
                description: "Leading the way the world understands, treats and defeats childhood cancer and other life-threatening diseases. Families never receive a bill from St. Jude for treatment, travel, housing or food — because all a family should worry about is helping their child live.",
                imageName: "heart.fill",
                category: "Health",
                donationGoal: 1000000,
                amountRaised: 750000,
                website: "https://stjude.org"
            )
        )
    }
}
