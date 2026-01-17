//
//  NotificationManager.swift
//  My Supplement
//
//  Push notification handling and scheduling
//

import Foundation
import UserNotifications

@MainActor
@Observable
final class NotificationManager {
    static let shared = NotificationManager()
    
    var isAuthorized = false
    var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    private init() {
        Task {
            await checkAuthorizationStatus()
        }
    }
    
    // MARK: - Authorization
    func checkAuthorizationStatus() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        authorizationStatus = settings.authorizationStatus
        isAuthorized = settings.authorizationStatus == .authorized
    }
    
    func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            await checkAuthorizationStatus()
            return granted
        } catch {
            print("❌ Notification authorization error: \(error)")
            return false
        }
    }
    
    // MARK: - Daily Reminder
    func scheduleDailyReminder(at time: Date, enabled: Bool) async {
        let center = UNUserNotificationCenter.current()
        
        // Remove existing daily reminders
        center.removePendingNotificationRequests(withIdentifiers: ["daily_reminder"])
        
        guard enabled else {
            print("📵 Daily reminder disabled")
            return
        }
        
        guard isAuthorized else {
            print("⚠️ Notifications not authorized")
            return
        }
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Time for Your Supplements! 💊"
        content.body = "Don't forget to take your daily supplements and earn coins!"
        content.sound = .default
        content.badge = 1
        
        // Create time trigger
        let calendar = Calendar.current
        var components = calendar.dateComponents([.hour, .minute], from: time)
        components.second = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        // Create request
        let request = UNNotificationRequest(
            identifier: "daily_reminder",
            content: content,
            trigger: trigger
        )
        
        do {
            try await center.add(request)
            print("✅ Daily reminder scheduled for \(components.hour ?? 0):\(String(format: "%02d", components.minute ?? 0))")
        } catch {
            print("❌ Failed to schedule daily reminder: \(error)")
        }
    }
    
    // MARK: - Supplement Reminders
    func scheduleSupplementReminder(
        supplementId: String,
        supplementName: String,
        at time: Date,
        timing: String // "morning", "midday", "evening"
    ) async {
        guard isAuthorized else { return }
        
        let center = UNUserNotificationCenter.current()
        let identifier = "supplement_\(supplementId)_\(timing)"
        
        // Remove existing
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        
        let content = UNMutableNotificationContent()
        content.title = "Supplement Reminder"
        content.body = "Time to take your \(supplementName)!"
        content.sound = .default
        content.userInfo = ["supplementId": supplementId, "timing": timing]
        
        let calendar = Calendar.current
        var components = calendar.dateComponents([.hour, .minute], from: time)
        components.second = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        do {
            try await center.add(request)
            print("✅ Reminder scheduled for \(supplementName) at \(timing)")
        } catch {
            print("❌ Failed to schedule reminder: \(error)")
        }
    }
    
    func cancelSupplementReminder(supplementId: String, timing: String) {
        let identifier = "supplement_\(supplementId)_\(timing)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func cancelAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("🗑️ All reminders cancelled")
    }
    
    // MARK: - Badge Management
    func clearBadge() async {
        let center = UNUserNotificationCenter.current()
        do {
            try await center.setBadgeCount(0)
        } catch {
            print("Failed to clear badge: \(error)")
        }
    }
    
    // MARK: - Pending Notifications
    func getPendingNotifications() async -> [UNNotificationRequest] {
        let center = UNUserNotificationCenter.current()
        return await center.pendingNotificationRequests()
    }
}
