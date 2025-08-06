//
//  ContentView.swift
//  WhyDonate
//
//  Created by Jibryll Brinkley on 7/30/25.
//

import SwiftUI

// MARK: - Main Tab View
struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    VStack(spacing: 4) {
                        Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                            .font(.system(size: 20))
                        Text("Home")
                            .font(DesignSystem.Typography.caption1)
                    }
                }
                .tag(0)

            ExploreView()
                .tabItem {
                    VStack(spacing: 4) {
                        Image(systemName: selectedTab == 1 ? "magnifyingglass.circle.fill" : "magnifyingglass")
                            .font(.system(size: 20))
                        Text("Explore")
                            .font(DesignSystem.Typography.caption1)
                    }
                }
                .tag(1)

            HistoryView()
                .tabItem {
                    VStack(spacing: 4) {
                        Image(systemName: selectedTab == 2 ? "clock.fill" : "clock")
                            .font(.system(size: 20))
                        Text("History")
                            .font(DesignSystem.Typography.caption1)
                    }
                }
                .tag(2)

            ProfileView()
                .tabItem {
                    VStack(spacing: 4) {
                        Image(systemName: selectedTab == 3 ? "person.crop.circle.fill" : "person.crop.circle")
                            .font(.system(size: 20))
                        Text("Profile")
                            .font(DesignSystem.Typography.caption1)
                    }
                }
                .tag(3)
        }
        .accentColor(DesignSystem.Colors.primary)
        .onAppear {
            // Customize tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.systemBackground
            
            // Normal state
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor.systemGray
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor.systemGray,
                .font: UIFont.systemFont(ofSize: 11, weight: .medium)
            ]
            
            // Selected state
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor(DesignSystem.Colors.primary)
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor(DesignSystem.Colors.primary),
                .font: UIFont.systemFont(ofSize: 11, weight: .semibold)
            ]
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

// MARK: - Preview
#Preview {
    MainTabView()
}
