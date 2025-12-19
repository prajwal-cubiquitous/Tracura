//
//  BadgeManager.swift
//  Tracura
//
//  Created for managing app icon badge count
//

import Foundation
import UIKit
import UserNotifications
import FirebaseAuth

/// Manager for app icon badge count
@MainActor
class BadgeManager {
    static let shared = BadgeManager()
    
    private init() {
        // Listen for notification updates
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNotificationUpdate),
            name: NSNotification.Name("NotificationManagerUpdated"),
            object: nil
        )
        
        // Listen for phase request updates
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePhaseRequestUpdate),
            name: NSNotification.Name("PhaseRequestsUpdated"),
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// Updates the app icon badge count based on current notification state
    /// This method calculates the total badge count including:
    /// - FCM notifications from NotificationManager
    /// - Phase requests (for ADMIN users only)
    func updateBadgeCount() {
        // Get base count from FCM notifications
        let fcmNotificationCount = NotificationManager.shared.totalUnreadCount
        
        // Check if user is ADMIN to include phase requests
        var phaseRequestCount = 0
        if let currentUser = Auth.auth().currentUser,
           let email = currentUser.email, !email.isEmpty {
            // This is an ADMIN user - phase requests should be included
            // Note: PhaseRequestNotificationViewModel is view-specific, so we'll update
            // badge when phase requests are loaded in views
            // For now, we'll use the base FCM count and let views update with phase requests
        }
        
        let totalCount = fcmNotificationCount + phaseRequestCount
        let badgeCount = max(0, totalCount) // Ensure non-negative
        UIApplication.shared.applicationIconBadgeNumber = badgeCount
        print("📱 App icon badge updated to: \(badgeCount) (FCM: \(fcmNotificationCount), Phase Requests: \(phaseRequestCount))")
    }
    
    /// Updates the app icon badge count with explicit counts
    /// - Parameters:
    ///   - fcmCount: Count of FCM notifications
    ///   - phaseRequestCount: Count of phase requests (for ADMIN users)
    func updateBadgeCount(fcmCount: Int, phaseRequestCount: Int = 0) {
        let totalCount = fcmCount + phaseRequestCount
        let badgeCount = max(0, totalCount) // Ensure non-negative
        UIApplication.shared.applicationIconBadgeNumber = badgeCount
        print("📱 App icon badge updated to: \(badgeCount) (FCM: \(fcmCount), Phase Requests: \(phaseRequestCount))")
    }
    
    /// Updates the app icon badge count
    /// - Parameter count: The badge count to set (0 to clear badge)
    func updateBadgeCount(_ count: Int) {
        let badgeCount = max(0, count) // Ensure non-negative
        UIApplication.shared.applicationIconBadgeNumber = badgeCount
        print("📱 App icon badge updated to: \(badgeCount)")
    }
    
    /// Clears the app icon badge
    func clearBadge() {
        UIApplication.shared.applicationIconBadgeNumber = 0
        print("📱 App icon badge cleared")
    }
    
    /// Gets the current badge count
    var currentBadgeCount: Int {
        return UIApplication.shared.applicationIconBadgeNumber
    }
    
    // MARK: - Notification Handlers
    
    @objc private func handleNotificationUpdate() {
        updateBadgeCount()
    }
    
    @objc private func handlePhaseRequestUpdate() {
        updateBadgeCount()
    }
}

