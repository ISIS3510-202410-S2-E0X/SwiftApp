//
//  NotificationHandler.swift
//  FoodBookApp
//
//  Created by Laura Restrepo on 17/03/24.
//

import Foundation
import UserNotifications

class NotificationHandler {
    
    func askPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
        { success, error in
            if success {
                print("Access granted!")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func cancelNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func sendLastReviewNotification(date: Date) {
        
        let notificationIdentifier = "lastReviewNotification"

        cancelNotification(identifier: notificationIdentifier)
                    
        let triggerDate = Calendar.current.date(byAdding: .day, value: 4, to: date)!
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: triggerDate), repeats: false)
                
        let content = UNMutableNotificationContent()
        content.title = "We miss you..."
        content.body = "You haven't left a review in the past 4 days"
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func sendLunchTimeReminder(identifier: String) {
        
        if hasDayPassedSinceLastNotification() {
            print("Sending daily notification...")
            let notificationIdentifier = "lunchTimeNotification"
            
            // i18n
            let title = "Time for lunch!"
            let body = "Looks like you're on campus, find your spot or rate the one you've been at!"
            
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = UNNotificationSound.default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(5), repeats: false) // Send notif almost immedtiately
            
            let request = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)
            
            saveLastNotificationTime(Date())
            UNUserNotificationCenter.current().add(request)
        }
        
    }
    
    private func saveLastNotificationTime(_ time: Date) {
        UserDefaults.standard.set(time, forKey: "lastNotificationTime")
    }

    // Function to retrieve the time of the last notification from local storage
    private func getLastNotificationTime() -> Date? {
        return UserDefaults.standard.object(forKey: "lastNotificationTime") as? Date
    }
    
    func hasDayPassedSinceLastNotification() -> Bool {
        guard let lastNotificationTime = getLastNotificationTime() else {
            // If no last notification time is stored, assume a day has passed
            return true
        }
        
        let currentDate = Date()
        let calendar = Calendar.current
        
        // Compare the dates to see if a day has passed
        if let lastNotificationDay = calendar.ordinality(of: .day, in: .era, for: lastNotificationTime),
           let currentDay = calendar.ordinality(of: .day, in: .era, for: currentDate) {
            return currentDay > lastNotificationDay
        }
        
        return false
    }
    
    // FIXME: Testing only
//    func hasMinutePassedSinceLastNotification() -> Bool {
//        guard let lastNotificationTime = getLastNotificationTime() else {
//            // If no last notification time is stored, assume a minute has passed
//            return true
//        }
//        
//        let currentDate = Date()
//        let calendar = Calendar.current
//        
//        // Compare the dates to see if a minute has passed
//        if let lastNotificationMinute = calendar.ordinality(of: .minute, in: .era, for: lastNotificationTime),
//           let currentMinute = calendar.ordinality(of: .minute, in: .era, for: currentDate) {
//            return currentMinute > lastNotificationMinute
//        }
//        
//        return false
//    }

}
