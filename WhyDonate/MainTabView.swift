//
//  ContentView.swift
//  WhyDonate
//
//  Created by Jibryll Brinkley on 7/30/25.
//

import SwiftUI

// MARK: - Main Tab View
struct MainTabView: View {
    // MARK: - Body
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            ExploreView()
                .tabItem {
                    Label("Explore", systemImage: "magnifyingglass")
                }
                .tag(1)

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
                .tag(2)

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
                .tag(3)
        }
        .accentColor(Color(red: 0.1, green: 0.2, blue: 0.4))
    }
}

// MARK: - Preview
#Preview {
    MainTabView()
}
