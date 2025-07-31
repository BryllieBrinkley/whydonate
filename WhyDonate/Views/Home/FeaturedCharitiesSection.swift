//
//  FeaturedCharitiesSection.swift
//  WhyDonate
//
//  Created by Jibryll Brinkley on 7/30/25.
//

import SwiftUI

struct FeaturedCharitiesSection: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Text("Featured Charities")
                .font(.headline)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(viewModel.featuredCharities) { charity in
                        CharityCardView(charity: charity)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}