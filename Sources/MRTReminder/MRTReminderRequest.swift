//
//  MRTReminderRequest.swift
//
//
//  Created by Ardli Fadhillah on 18/07/23.
//

import CoreLocation
import UserNotifications

public class MRTReminderRequest: NSObject {
    public let ticketId: String
    private var destinationName: String
    private var destinationCoordinate = CLLocationCoordinate2D()
    private var reminderRadius: Double
    public private(set) var reminderEnabled = true
    
    public init(ticketId: String, destinationName: String, destinationCoordinate: (latitude: Double, longitude: Double), reminderRadius: Double = 2) {
        self.ticketId = ticketId
        self.destinationName = destinationName
        self.destinationCoordinate.latitude = destinationCoordinate.latitude
        self.destinationCoordinate.longitude = destinationCoordinate.longitude
        self.reminderRadius = reminderRadius
    }
    
    public func changeDestination(name: String, coordinate: (latitude: Double, longitude: Double)) {
        self.destinationName = name
        self.destinationCoordinate.latitude = coordinate.latitude
        self.destinationCoordinate.longitude = coordinate.longitude
    }
    
    public func changeActiveState(to enabled: Bool) {
        self.reminderEnabled = enabled
    }
    
    public func setReminderRadius(to radius: Double) {
        self.reminderRadius = radius
    }
    
    private lazy var destinationLocation = createDestination()
    private func createDestination() -> CLCircularRegion {
        let region = CLCircularRegion(
            center: destinationCoordinate,
            radius: reminderRadius,
            identifier: UUID().uuidString)
        region.notifyOnEntry = true
        return region
    }
    
    public func startReminder() {
        guard MRTReminderCenter.shared.isNotificationAllowed() else { return }
        guard reminderEnabled else { return }
        
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "You've Arrived!"
        notificationContent.body = "Get off at \(destinationName) station now."
        
        let trigger = UNLocationNotificationTrigger(region: destinationLocation, repeats: false)
        
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

extension MRTReminderRequest: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
        MRTReminderCenter.shared.removeReminder(request: self)
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if #available(iOS 14.0, *) {
            completionHandler(.banner)
            MRTReminderCenter.shared.removeReminder(request: self)
        }
    }
}
