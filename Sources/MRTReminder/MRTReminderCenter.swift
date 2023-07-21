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
    
    private lazy var locationManager = makeLocationManager()
    private func makeLocationManager() -> CLLocationManager {
        let manager = CLLocationManager()
        manager.allowsBackgroundLocationUpdates = true
        return manager
    }
    
    public func requestLocationPermission() {
        switch locationManager.authorizationStatus {
        case .notDetermined, .denied, .restricted:
            locationManager.requestWhenInUseAuthorization()
        default:
            break
        }
    }
    
    public func setReminder(request: MRTReminderRequest) {
        print("Checking Notification Permission")
        notificationCenter.getNotificationSettings() { settings in
            if settings.authorizationStatus == .authorized {
                print("Notification Permission Authorized!!!")
                self.activateReminder(request: request)
            }
        }
    }
    private func activateReminder(request: MRTReminderRequest) {
        
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "You've Arrived!"
        notificationContent.body = "Get off at \(request.destinationName) station now."
        
        let trigger = UNLocationNotificationTrigger(region: request.destinationLocation, repeats: false)
        
        let notifRequest = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: notificationContent,
            trigger: trigger)
        
        print("Adding Notification Request")
        
        notificationCenter.add(notifRequest) { error in
            if error != nil {
                print("Error: \(String(describing: error))")
            }
            else {
                print("Notification Added!!!")
                self.notificationCenter.delegate = self
                self.locationManager.delegate = self
                self.locationManager.startMonitoring(for: request.destinationLocation)
            }
        }
    }
}

extension MRTReminderCenter: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Notification Finished 1")
        completionHandler()
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Notification Finished 2")
        completionHandler(.banner)
    }
}

extension MRTReminderCenter: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("User entered the region")
        MRTReminderHaptics.shared.playVibration(duration: 0.5, delay: 0.5, repetition: 3)
        self.locationManager.stopMonitoring(for: region)
    }
}
