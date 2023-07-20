//
//  MRTReminderCenter.swift
//
//
//  Created by Ardli Fadhillah on 18/07/23.
//

import CoreLocation
import UserNotifications

public class MRTReminderCenter {
    public static let shared = MRTReminderCenter()
    private init() {}
    
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
    
    private var reminderList = [MRTReminderRequest]()
    
    public func addReminderRequest(_ request: MRTReminderRequest) {
        reminderList.append(request)
    }
    
    public func activateReminder(ticketId: String) {
        if let request = getReminderRequest(ticketId: ticketId) {
            request.startReminder()
        }
    }
    
    public func removeReminder(request: MRTReminderRequest) {
        reminderList.removeAll(where: { $0.ticketId == request.ticketId })
    }
    
    public func getReminderRequest(ticketId: String) -> MRTReminderRequest? {
        return reminderList.first(where: { $0.ticketId == ticketId } )
    }
}
