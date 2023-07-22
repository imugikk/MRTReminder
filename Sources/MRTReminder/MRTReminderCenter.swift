//
//  MRTReminderCenter.swift
//
//
//  Created by Ardli Fadhillah on 18/07/23.
//

import CoreLocation
import UserNotifications
import UIKit

public class MRTReminderCenter: NSObject {
    public static let shared = MRTReminderCenter()
    private override init() { super.init() }
    
    private var currentRequest: MRTReminderRequest!
    public var delegate: MRTReminderProgressDelegate?
    
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
    
    private let notificationCenter = UNUserNotificationCenter.current()
    public func requestNotificationPermission() {
        let options: UNAuthorizationOptions = [.alert, .sound]
      notificationCenter.requestAuthorization(options: options) { _, _ in }
    }
    
    public private(set) var reminderRadius: Double = 250
    public func setReminderRadius(to radius: Double) {
        self.reminderRadius = radius
    }
        
    public func activateReminder(request: MRTReminderRequest) {
        notificationCenter.delegate = self
        locationManager.delegate = self
        
        currentRequest = request
        if let nextStation = request.getNextStation()?.region {
            print("Monitoring Started...")
            locationManager.startMonitoring(for: nextStation)
        }
    }
    
    public func activateNotification(title: String, body: String, at station: MRTReminderStation) {
        notificationCenter.getNotificationSettings() { settings in
            if settings.authorizationStatus == .authorized {
                self.createNotification(title: title, body: body, at: station)
            }
        }
    }
    private func createNotification(title: String, body: String, at station: MRTReminderStation) {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = title
        notificationContent.body = body
        notificationContent.sound = .default
        
        let trigger = UNLocationNotificationTrigger(region: station.region, repeats: false)
        
        let notifRequest = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: notificationContent,
            trigger: trigger)
        
        notificationCenter.add(notifRequest) { error in
            if error != nil {
                print("Error: \(String(describing: error))")
            }
            else {
                print("Notification Added!!!")
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
        if UIApplication.shared.applicationState == .active {
            MRTReminderHaptics.shared.playVibration(duration: 0.5, delay: 0.5, repetition: 3)
        }
        completionHandler(.banner)
    }
}

extension MRTReminderCenter: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("User entered the region")
        self.locationManager.stopMonitoring(for: region)
        self.currentRequest.updateCurrentStatus()
        self.delegate?.reminderProgressUpdated(stationsTraveled: currentRequest.stationsTraveled,
                                               stationsRemaining: currentRequest.stationsRemaining,
                                               totalStations: currentRequest.stationCount)
        
        if currentRequest.stationsRemaining > 0, let nextStation = currentRequest.getNextStation() {
            print("Monitoring Next Region...")
            locationManager.startMonitoring(for: nextStation.region)
//            if currentRequest.stationsRemaining == 2 {
//                activateNotification(title: "You almost arrive!",
//                                     body: "You have 1 station left. Get ready to get off!",
//                                     at: nextStation)
//            }
//            else if currentRequest.stationsRemaining == 1 {
//                activateNotification(title: "You’ve arrived!",
//                                     body: "Get off at \(nextStation.name) station now.",
//                                     at: nextStation)
//            }
        }
    }
}
