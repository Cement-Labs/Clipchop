//
//  File.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/8/13.
//

import SwiftUI
import UserNotifications

extension AppDelegate: UNUserNotificationCenterDelegate {
    // Implementation is necessary to show notifications even when the app has focus!
    func userNotificationCenter(
        _: UNUserNotificationCenter,
        willPresent _: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> ()
    ) {
        completionHandler([.banner])
    }

    static func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert]
        ) { accepted, error in
            if !accepted {
                print("User Notification access denied.")
            }
            if let error {
                print(error.localizedDescription)
            }
        }
    }

    static func areNotificationsEnabled() -> Bool {
        let group = DispatchGroup()
        group.enter()

        var notificationsEnabled = false

        UNUserNotificationCenter.current().getNotificationSettings { notificationSettings in
            notificationsEnabled = notificationSettings.authorizationStatus != UNAuthorizationStatus.denied
            group.leave()
        }

        group.wait()
        return notificationsEnabled
    }

    static func sendNotification(_ content: UNMutableNotificationContent) {
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(
            identifier: uuidString,
            content: content,
            trigger: nil
        )

        requestNotificationAuthorization()

        UNUserNotificationCenter.current().add(request)
    }

    static func sendNotification(_ title: String, _ body: String) {
        let content = UNMutableNotificationContent()

        content.title = title
        content.body = body
        content.categoryIdentifier = UUID().uuidString

        AppDelegate.sendNotification(content)
    }
}
