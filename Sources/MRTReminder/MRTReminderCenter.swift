//
//  MRTReminderCenter.swift
//
//
//  Created by Ardli Fadhillah on 18/07/23.
//

import CoreLocation
import UserNotifications

public class MRTReminderCenter: NSObject {
    public static let shared = MRTReminderCenter()
    private override init() { super.init() }
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    public func requestNotificationPermission() {
      let options: UNAuthorizationOptions = [.alert]
      notificationCenter.requestAuthorization(options: options) { _, _ in }
    }
    
    public func isNotificationAllowed() -> Bool {
        var authorized = false
        notificationCenter.getNotificationSettings() { settings in
            authorized = settings.authorizationStatus == .authorized
        }
        return authorized
    }
    
    private lazy var locationManager = makeLocationManager()
    private func makeLocationManager() -> CLLocationManager {
        let manager = CLLocationManager()
        manager.allowsBackgroundLocationUpdates = true
        return manager
    }
    
    public func requestLocationPermission() {
        if #available(iOS 14.0, *) {
            switch locationManager.authorizationStatus {
            case .notDetermined, .denied, .restricted:
                locationManager.requestWhenInUseAuthorization()
            default:
                break
            }
        }
    }
    
    public func activateReminder(request: MRTReminderRequest) {
        guard isNotificationAllowed() else { return }
        
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "You've Arrived!"
        notificationContent.body = "Get off at \(request.destinationName) station now."
        
        let trigger = UNLocationNotificationTrigger(region: request.destinationLocation, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: notificationContent,
            trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if error != nil {
                print("Error: \(String(describing: error))")
            }
            else {
                UNUserNotificationCenter.current().delegate = self
            }
        }
    }
}

extension MRTReminderCenter: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if #available(iOS 14.0, *) {
            completionHandler(.banner)
        }
    }
}
