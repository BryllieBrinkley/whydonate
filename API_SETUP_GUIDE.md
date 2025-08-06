# API Key Setup Guide for WhyDonate

## 🚀 Getting Your API Key

### Step 1: Choose Your API Provider

#### Option A: Charity Navigator API (Recommended)
- **URL**: https://www.charitynavigator.org/developers
- **Cost**: Free tier available
- **Coverage**: US nonprofits with ratings and financial data
- **Rate Limits**: 60 requests/minute, 1000 requests/hour

#### Option B: IRS Exempt Organizations API
- **URL**: https://www.irs.gov/charities-non-profits/exempt-organizations-business-master-file-eo-bmf
- **Cost**: Free
- **Coverage**: US nonprofits only
- **Rate Limits**: No strict limits

#### Option C: Guidestar API
- **URL**: https://www.guidestar.org/developer
- **Cost**: Paid service
- **Coverage**: Comprehensive nonprofit data
- **Rate Limits**: Varies by plan

### Step 2: Register for API Access

#### For Charity Navigator:
1. Visit https://www.charitynavigator.org/developers
2. Click "Get Started" or "Sign Up"
3. Fill out the registration form
4. Verify your email address
5. Submit API access request
6. Wait for approval (usually 1-2 business days)
7. Receive your API key via email

#### For IRS API:
1. No registration required
2. Use the public endpoint directly
3. No API key needed

### Step 3: Configure Your API Key

1. **Open the configuration file**:
   ```
   WhyDonate/Services/APIConfiguration.swift
   ```

2. **Replace the placeholder**:
   ```swift
   // Find this line:
   static let charityNavigatorAPIKey = "YOUR_ACTUAL_API_KEY_HERE"
   
   // Replace with your actual API key:
   static let charityNavigatorAPIKey = "abc123def456ghi789"
   ```

3. **Test the configuration**:
   - Build and run the app
   - Check the console logs for API key status
   - Verify that live data is being fetched

## 🔧 Implementation Details

### API Response Structure

When you get your API key, you'll need to implement the actual response parsing. Here's what to do:

1. **Uncomment the response models** in `IRSCharityAPIService.swift`:
   ```swift
   // Remove the /* */ around these models:
   struct CharityAPIResponse: Codable {
       let organizations: [APICharity]
       let totalCount: Int
       let page: Int
       let pageSize: Int
   }
   ```

2. **Update the decodeCharities method**:
   ```swift
   private func decodeCharities(from data: Data) throws -> [CharityModel] {
       let decoder = JSONDecoder()
       decoder.keyDecodingStrategy = .convertFromSnakeCase
       
       let response = try decoder.decode(CharityAPIResponse.self, from: data)
       return response.organizations.map { apiCharity in
           CharityModel(
               name: apiCharity.name,
               description: apiCharity.mission,
               imageName: "building.2.crop.circle",
               category: apiCharity.category,
               rating: apiCharity.rating,
               isUrgent: false,
               verified: apiCharity.isVerified,
               donationGoal: nil,
               amountRaised: nil,
               location: "\(apiCharity.city), \(apiCharity.state)",
               website: apiCharity.website,
               mission: apiCharity.mission,
               ein: apiCharity.ein
           )
       }
   }
   ```

### Error Handling

The app includes comprehensive error handling for:
- **Invalid API Key**: 401 errors
- **Rate Limiting**: 429 errors
- **Network Issues**: Connection timeouts
- **Server Errors**: 500+ errors

### Fallback Data

The app will automatically use fallback data when:
- No API key is configured
- API requests fail
- Network is unavailable

## 🔒 Security Best Practices

### 1. Never Commit API Keys
```bash
# Add to .gitignore
APIConfiguration.swift
```

### 2. Use Environment Variables (Production)
```swift
// In production, use environment variables
static let charityNavigatorAPIKey = ProcessInfo.processInfo.environment["CHARITY_API_KEY"] ?? "fallback_key"
```

### 3. Use Keychain (iOS)
```swift
import Security

class KeychainManager {
    static func saveAPIKey(_ key: String) {
        // Implementation for saving to Keychain
    }
    
    static func getAPIKey() -> String? {
        // Implementation for retrieving from Keychain
    }
}
```

### 4. API Key Rotation
- Regularly rotate your API keys
- Monitor API usage
- Set up alerts for rate limit approaching

## 🧪 Testing Your API Key

### 1. Console Logs
Check the Xcode console for these messages:
```
✅ Valid API key configured
✅ Successfully fetched X charities from API
```

### 2. Network Tab
In Xcode's Network tab, you should see:
- API requests to charitynavigator.org
- Proper headers with your API key
- Successful responses (200 status codes)

### 3. App Behavior
- Live data should load instead of fallback data
- Search functionality should work with real results
- Categories should reflect actual charity categories

## 🚨 Troubleshooting

### Common Issues

#### 1. "Invalid API Key" Error
**Cause**: API key is incorrect or expired
**Solution**: 
- Verify your API key is correct
- Check if your API access is still active
- Try regenerating your API key

#### 2. "Rate Limit Exceeded" Error
**Cause**: Too many API requests
**Solution**:
- Implement caching to reduce API calls
- Add delays between requests
- Upgrade your API plan if needed

#### 3. "Network Error" 
**Cause**: No internet connection or API server down
**Solution**:
- Check your internet connection
- Verify the API endpoint is accessible
- Check API provider status page

#### 4. "Decoding Error"
**Cause**: API response format doesn't match expected structure
**Solution**:
- Update the response models to match actual API
- Check API documentation for correct field names
- Add proper error handling for missing fields

### Debug Steps

1. **Enable Debug Logging**:
   ```swift
   // In APIConfiguration.swift
   static let debugMode = true
   ```

2. **Check API Key Status**:
   ```swift
   let status = charityAPIService.getAPIKeyStatus()
   print("API Key Valid: \(status.isValid)")
   print("Using Fallback: \(status.isUsingFallback)")
   ```

3. **Test API Endpoint**:
   ```bash
   curl -H "Authorization: Bearer YOUR_API_KEY" \
        -H "Content-Type: application/json" \
        "https://api.charitynavigator.org/v2/organizations?page=1&pageSize=5"
   ```

## 📊 Monitoring and Analytics

### API Usage Tracking
```swift
class APIUsageTracker {
    static func trackRequest() {
        // Track API requests for monitoring
    }
    
    static func checkRateLimit() {
        // Check if approaching rate limits
    }
}
```

### Performance Monitoring
- Monitor API response times
- Track success/failure rates
- Monitor data freshness

## 🎯 Next Steps

1. **Get your API key** from Charity Navigator
2. **Update the configuration** with your key
3. **Test the integration** with live data
4. **Implement caching** for better performance
5. **Add error handling** for production use
6. **Monitor usage** to stay within limits

## 📞 Support

If you need help:
- Check the API provider's documentation
- Review the console logs for error messages
- Test with a simple curl request
- Contact the API provider's support team

---

**Remember**: The app will work with fallback data even without an API key, so you can continue development while waiting for API access approval. 