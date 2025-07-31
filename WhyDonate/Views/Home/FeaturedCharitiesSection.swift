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
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Featured Charities")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Handpicked organizations making a difference")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("See All") {
                    // Navigate to all featured charities
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            .padding(.horizontal)
            
            // Charity cards with lazy loading
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(viewModel.featuredCharities) { charity in
                        NavigationLink(destination: CharityDetailView(charity: charity)) {
                            CharityCardView(charity: charity)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 4)
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