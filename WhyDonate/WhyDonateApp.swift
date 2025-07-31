//
//  WhyDonateApp.swift
//  WhyDonate
//
//  Created by Jibryll Brinkley on 7/30/25.
//

import SwiftUI

@main
struct WhyDonateApp: App {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if appState.isInitializing {
                    SplashView()
                        .task {
                            await appState.initialize()
                        }
                } else if hasSeenOnboarding {
                    MainTabView()
                        .environmentObject(appState)
                } else {
                    OnboardingView()
                        .environmentObject(appState)
                }
            }
            .preferredColorScheme(appState.colorScheme)
        }
    }
}

// MARK: - App State Manager
@MainActor
class AppState: ObservableObject {
    @Published var isInitializing = true
    @Published var colorScheme: ColorScheme? = nil
    @Published var hasNetworkConnection = true
    
    private let charityViewModel = CharityViewModel.shared
    
    func initialize() async {
        // Simulate app initialization and preload critical data
        async let charityDataLoad: Void = preloadCharityData()
        async let settingsLoad: Void = loadUserSettings()
        async let networkCheck: Void = checkNetworkConnection()
        
        // Wait for all initialization tasks
        await charityDataLoad
        await settingsLoad
        await networkCheck
        
        // Add minimum splash duration for better UX
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        isInitializing = false
    }
    
    private func preloadCharityData() async {
        // Load cached data first, then refresh if needed
        charityViewModel.loadInitialData()
        
        // If no cached data, load fresh data
        if charityViewModel.allCharities.isEmpty {
            await charityViewModel.refreshData()
        }
    }
    
    private func loadUserSettings() async {
        // Load user preferences
        if let colorSchemeRaw = UserDefaults.standard.object(forKey: "colorScheme") as? String {
            switch colorSchemeRaw {
            case "dark":
                colorScheme = .dark
            case "light":
                colorScheme = .light
            default:
                colorScheme = nil
            }
        }
    }
    
    private func checkNetworkConnection() async {
        // Basic network connectivity check
        // In a real app, you might use Network framework
        hasNetworkConnection = true
    }
    
    func updateColorScheme(_ scheme: ColorScheme?) {
        colorScheme = scheme
        
        let schemeString: String
        switch scheme {
        case .dark:
            schemeString = "dark"
        case .light:
            schemeString = "light"
        case nil:
            schemeString = "system"
        }
        
        UserDefaults.standard.set(schemeString, forKey: "colorScheme")
    }
}

// MARK: - Splash View
struct SplashView: View {
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0.0
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // App logo/icon
                Image(systemName: "heart.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.0)) {
                            logoScale = 1.0
                            logoOpacity = 1.0
                        }
                    }
                
                VStack(spacing: 8) {
                    Text("WhyDonate")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .opacity(logoOpacity)
                    
                    Text("Making giving effortless and impactful")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .opacity(logoOpacity)
                }
                
                ProgressView()
                    .scaleEffect(1.2)
                    .opacity(logoOpacity)
            }
        }
        .animation(.easeInOut(duration: 0.8).delay(0.2), value: logoOpacity)
    }
}
