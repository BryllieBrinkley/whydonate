import Foundation

// MARK: - API Configuration
struct APIConfiguration {
    
    // MARK: - API Keys
    // To get your actual API key:
    // 1. Visit https://www.charitynavigator.org/developers
    // 2. Sign up for a developer account
    // 3. Request API access
    // 4. Replace the placeholder below with your actual API key
    
    // Production API Key (replace with your actual key)
    static let charityNavigatorAPIKey = "YOUR_ACTUAL_API_KEY_HERE"
    
    // Fallback API Key for development/testing
    static let fallbackAPIKey = "demo_key"
    
    // MARK: - API Endpoints
    static let charityNavigatorBaseURL = "https://api.charitynavigator.org/v2"
    static let irsBaseURL = "https://apps.irs.gov/app/eos/teosearch.jsp"
    
    // MARK: - API Limits
    static let maxRequestsPerMinute = 60
    static let maxRequestsPerHour = 1000
    
    // MARK: - Request Headers
    static func headers(for apiKey: String) -> [String: String] {
        return [
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "application/json",
            "Accept": "application/json",
            "User-Agent": "WhyDonate/1.0 (iOS)"
        ]
    }
    
    // MARK: - API Key Management
    static var currentAPIKey: String {
        // In production, you might want to store this in Keychain
        // For now, we'll use a simple approach
        return charityNavigatorAPIKey != "YOUR_ACTUAL_API_KEY_HERE" 
            ? charityNavigatorAPIKey 
            : fallbackAPIKey
    }
    
    // MARK: - Environment Detection
    static var isProduction: Bool {
        #if DEBUG
        return false
        #else
        return true
        #endif
    }
    
    // MARK: - API Key Validation
    static func isValidAPIKey(_ key: String) -> Bool {
        return key != "YOUR_ACTUAL_API_KEY_HERE" && 
               key != "demo_key" && 
               !key.isEmpty
    }
}

// MARK: - API Key Instructions
/*
 
 ========================================
 SETTING UP YOUR ACTUAL API KEY
 ========================================
 
 1. GET YOUR API KEY:
    - Visit: https://www.charitynavigator.org/developers
    - Sign up for a developer account
    - Request API access
    - You'll receive an API key via email
 
 2. REPLACE THE PLACEHOLDER:
    - Open this file: WhyDonate/Services/APIConfiguration.swift
    - Find the line: static let charityNavigatorAPIKey = "YOUR_ACTUAL_API_KEY_HERE"
    - Replace "YOUR_ACTUAL_API_KEY_HERE" with your actual API key
 
 3. SECURITY CONSIDERATIONS:
    - Never commit API keys to version control
    - Consider using Keychain for production apps
    - Use environment variables for CI/CD pipelines
 
 4. TESTING:
    - The app will use fallback data if no valid API key is provided
    - Once you add a real API key, the app will fetch live data
 
 5. API LIMITS:
    - Charity Navigator API has rate limits
    - Monitor your usage to avoid hitting limits
    - Implement caching to reduce API calls
 
 ========================================
 ALTERNATIVE API SOURCES
 ========================================
 
 If Charity Navigator doesn't work for you, consider:
 
 1. IRS Exempt Organizations API:
    - Free, no API key required
    - Limited to US organizations
    - Basic information only
 
 2. Guidestar API:
    - Requires registration
    - Comprehensive nonprofit data
    - Paid service for advanced features
 
 3. OpenCorporates API:
    - Free tier available
    - Global nonprofit data
    - Requires registration
 
 ========================================
 IMPLEMENTATION STEPS
 ========================================
 
 1. Update APIConfiguration.swift with your API key
 2. Test the API connection
 3. Implement proper error handling
 4. Add caching for better performance
 5. Monitor API usage and limits
 
 */ 