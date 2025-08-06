//
//  FeaturedCharitiesSection.swift
//  WhyDonate
//
//  Created by Jibryll Brinkley on 7/30/25.
//

import SwiftUI

struct FeaturedCharitiesSection: View {
    @ObservedObject var viewModel: CharityViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            // Section header
            HStack {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text("Featured Charities")
                        .font(DesignSystem.Typography.title2)
                        .fontWeight(.bold)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                    
                    Text("Handpicked organizations making a difference")
                        .font(DesignSystem.Typography.subheadline)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
                
                Spacer()
                
                Button("See All") {
                    // Navigate to all featured charities
                }
                .font(DesignSystem.Typography.subheadline)
                .fontWeight(.medium)
                .foregroundColor(DesignSystem.Colors.primary)
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            
            // Charity cards with lazy loading
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: DesignSystem.Spacing.md) {
                    ForEach(viewModel.featuredCharities) { charity in
                        NavigationLink(destination: CharityDetailView(charity: charity)) {
                            CharityCardView(charity: charity)
                                .frame(width: 280)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.xs)
            }
            .scrollClipDisabled()
        }
    }
}

// MARK: - Preview
#Preview {
    FeaturedCharitiesSection(viewModel: CharityViewModel.shared)
        .padding()
}