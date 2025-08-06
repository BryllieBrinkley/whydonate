import SwiftUI

struct ProfileView: View {
    @State private var showingSettings = false
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: DesignSystem.Spacing.sectionSpacing) {
                    // Profile header
                    profileHeaderSection
                    
                    // Statistics section
                    statisticsSection
                    
                    // Quick actions
                    quickActionsSection
                    
                    // Settings section
                    settingsSection
                    
                    // Support section
                    supportSection
                }
                .padding(.vertical, DesignSystem.Spacing.md)
            }
            .background(DesignSystem.Colors.background)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .alert("Log Out", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Log Out", role: .destructive) {
                    // Handle logout
                }
            } message: {
                Text("Are you sure you want to log out?")
            }
        }
    }
    
    // MARK: - Profile Header Section
    private var profileHeaderSection: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Profile image and name
            VStack(spacing: DesignSystem.Spacing.md) {
                // Profile image
                ZStack {
                    Circle()
                        .fill(DesignSystem.Colors.primaryGradient)
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "person.fill")
                        .font(.system(size: 40, weight: .medium))
                        .foregroundColor(.white)
                }
                .shadow(
                    color: DesignSystem.Shadows.medium.color,
                    radius: DesignSystem.Shadows.medium.radius,
                    x: DesignSystem.Shadows.medium.x,
                    y: DesignSystem.Shadows.medium.y
                )
                
                VStack(spacing: DesignSystem.Spacing.xs) {
                    Text("John Doe")
                        .font(DesignSystem.Typography.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                    
                    Text("john.doe@email.com")
                        .font(DesignSystem.Typography.subheadline)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
            }
            
            // Edit profile button
            Button("Edit Profile") {
                // Navigate to edit profile
            }
            .secondaryButtonStyle()
            .padding(.horizontal, DesignSystem.Spacing.lg)
        }
        .padding(DesignSystem.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                .fill(DesignSystem.Colors.cardBackground)
                .shadow(
                    color: DesignSystem.Shadows.small.color,
                    radius: DesignSystem.Shadows.small.radius,
                    x: DesignSystem.Shadows.small.x,
                    y: DesignSystem.Shadows.small.y
                )
        )
        .padding(.horizontal, DesignSystem.Spacing.md)
    }
    
    // MARK: - Statistics Section
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Your Impact")
                .font(DesignSystem.Typography.headline)
                .fontWeight(.semibold)
                .foregroundColor(DesignSystem.Colors.primaryText)
                .padding(.horizontal, DesignSystem.Spacing.md)
            
            HStack(spacing: DesignSystem.Spacing.md) {
                ProfileStatCard(
                    title: "Total Donated",
                    value: "$1,250",
                    subtitle: "This year",
                    icon: "dollarsign.circle.fill",
                    color: DesignSystem.Colors.success
                )
                
                ProfileStatCard(
                    title: "Charities",
                    value: "8",
                    subtitle: "Supported",
                    icon: "heart.fill",
                    color: DesignSystem.Colors.primary
                )
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
        }
    }
    
    // MARK: - Quick Actions Section
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Quick Actions")
                .font(DesignSystem.Typography.headline)
                .fontWeight(.semibold)
                .foregroundColor(DesignSystem.Colors.primaryText)
                .padding(.horizontal, DesignSystem.Spacing.md)
            
            VStack(spacing: DesignSystem.Spacing.sm) {
                QuickActionRow(
                    title: "Donation History",
                    subtitle: "View your giving history",
                    icon: "clock.fill",
                    color: DesignSystem.Colors.primary
                ) {
                    // Navigate to history
                }
                
                QuickActionRow(
                    title: "Saved Charities",
                    subtitle: "Your favorite organizations",
                    icon: "heart.fill",
                    color: DesignSystem.Colors.secondary
                ) {
                    // Navigate to saved charities
                }
                
                QuickActionRow(
                    title: "Tax Receipts",
                    subtitle: "Download donation receipts",
                    icon: "doc.text.fill",
                    color: DesignSystem.Colors.accent
                ) {
                    // Navigate to tax receipts
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
        }
    }
    
    // MARK: - Settings Section
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Settings")
                .font(DesignSystem.Typography.headline)
                .fontWeight(.semibold)
                .foregroundColor(DesignSystem.Colors.primaryText)
                .padding(.horizontal, DesignSystem.Spacing.md)
            
            VStack(spacing: DesignSystem.Spacing.sm) {
                SettingsRow(
                    title: "Notifications",
                    subtitle: "Manage your notifications",
                    icon: "bell.fill",
                    color: DesignSystem.Colors.info
                ) {
                    showingSettings = true
                }
                
                SettingsRow(
                    title: "Privacy & Security",
                    subtitle: "Manage your privacy settings",
                    icon: "lock.fill",
                    color: DesignSystem.Colors.warning
                ) {
                    showingSettings = true
                }
                
                SettingsRow(
                    title: "Payment Methods",
                    subtitle: "Manage your payment options",
                    icon: "creditcard.fill",
                    color: DesignSystem.Colors.success
                ) {
                    showingSettings = true
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
        }
    }
    
    // MARK: - Support Section
    private var supportSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Support")
                .font(DesignSystem.Typography.headline)
                .fontWeight(.semibold)
                .foregroundColor(DesignSystem.Colors.primaryText)
                .padding(.horizontal, DesignSystem.Spacing.md)
            
            VStack(spacing: DesignSystem.Spacing.sm) {
                SettingsRow(
                    title: "Help & Support",
                    subtitle: "Get help and contact us",
                    icon: "questionmark.circle.fill",
                    color: DesignSystem.Colors.info
                ) {
                    // Navigate to help
                }
                
                SettingsRow(
                    title: "About WhyDonate",
                    subtitle: "Learn more about the app",
                    icon: "info.circle.fill",
                    color: DesignSystem.Colors.secondary
                ) {
                    // Navigate to about
                }
                
                SettingsRow(
                    title: "Log Out",
                    subtitle: "Sign out of your account",
                    icon: "rectangle.portrait.and.arrow.right",
                    color: DesignSystem.Colors.error
                ) {
                    showingLogoutAlert = true
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
        }
    }
}

// MARK: - Profile Stat Card Component
struct ProfileStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(DesignSystem.Typography.title3)
                    .fontWeight(.bold)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                
                Text(title)
                    .font(DesignSystem.Typography.caption1)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                
                Text(subtitle)
                    .font(DesignSystem.Typography.caption2)
                    .foregroundColor(DesignSystem.Colors.tertiaryText)
            }
        }
        .padding(DesignSystem.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                .fill(DesignSystem.Colors.cardBackground)
                .shadow(
                    color: DesignSystem.Shadows.small.color,
                    radius: DesignSystem.Shadows.small.radius,
                    x: DesignSystem.Shadows.small.x,
                    y: DesignSystem.Shadows.small.y
                )
        )
    }
}

// MARK: - Quick Action Row Component
struct QuickActionRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(color)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(DesignSystem.Typography.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                    
                    Text(subtitle)
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.tertiaryText)
            }
            .padding(DesignSystem.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .fill(DesignSystem.Colors.cardBackground)
                    .shadow(
                        color: DesignSystem.Shadows.small.color,
                        radius: DesignSystem.Shadows.small.radius,
                        x: DesignSystem.Shadows.small.x,
                        y: DesignSystem.Shadows.small.y
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Settings Row Component
struct SettingsRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(color)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(DesignSystem.Typography.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(DesignSystem.Colors.primaryText)
                    
                    Text(subtitle)
                        .font(DesignSystem.Typography.caption1)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.tertiaryText)
            }
            .padding(DesignSystem.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .fill(DesignSystem.Colors.cardBackground)
                    .shadow(
                        color: DesignSystem.Shadows.small.color,
                        radius: DesignSystem.Shadows.small.radius,
                        x: DesignSystem.Shadows.small.x,
                        y: DesignSystem.Shadows.small.y
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Settings View (Placeholder)
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Text("Settings")
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
        }
    }
}

// MARK: - Preview
#Preview {
    ProfileView()
}
