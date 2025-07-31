//
//  WhyDonateApp.swift
//  WhyDonate
//
//  Created by Jibryll Brinkley on 7/30/25.
//

import SwiftUI
import os.log

// MARK: - WhyDonate App
@main
struct WhyDonateApp: App {
    // MARK: - Properties
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    private let logger = Logger(subsystem: "com.whydonate.app", category: "App")
    
    // MARK: - Body
    var body: some Scene {
        WindowGroup {
            Group {
                if hasSeenOnboarding {
                    MainTabView()
                        .onAppear {
                            logger.info("App launched - showing main interface")
                        }
                } else {
                    OnboardingView()
                        .onAppear {
                            logger.info("App launched - showing onboarding")
                        }
                }
            }
            .onAppear {
                setupApp()
            }
        }
    }
    
    // MARK: - Private Methods
    private func setupApp() {
        // Configure app-wide settings
        configureAppearance()
        logger.info("WhyDonate app initialized")
    }
    
    private func configureAppearance() {
        // Set up global appearance for consistent styling
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color(red: 0.1, green: 0.2, blue: 0.4))
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
}
