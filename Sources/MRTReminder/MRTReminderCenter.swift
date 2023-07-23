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
    
    public private(set) var currentRequest: MRTReminderRequest!
    private var regionIndex = [CLRegion: Int]()
    
    public var isReminderEnabled = true
    public var isHapticEnabled = true
    public var isSoundEnabled = true
    private var passiveNotification = false
    
    //Location Manager and Permission
    private lazy var locationManager = makeLocationManager()
    private func makeLocationManager() -> CLLocationManager {
        let manager = CLLocationManager()
        manager.allowsBackgroundLocationUpdates = true
        return manager
    }
    public func requestLocationPermission() {
        locationManager.requestAlwaysAuthorization()
    }
    
    //Notification Center and Permission
    private let notificationCenter = UNUserNotificationCenter.current()
    public func requestNotificationPermission() {
        let options: UNAuthorizationOptions = [.alert, .sound]
      notificationCenter.requestAuthorization(options: options) { _, _ in }
    }
    
    public private(set) var reminderRadius: Double = 250
    public func setReminderRadius(inMeters radius: Double) {
        self.reminderRadius = radius
        self.reminderRadius = min(radius, locationManager.maximumRegionMonitoringDistance)
    }
    
    public private(set) var averageDurationPerStation: Double = 2.0
    public func setAverageDurationPerStation(inMinutes duration: Double) {
        self.averageDurationPerStation = duration
    }
    
    public var progressDelegate: MRTReminderProgressDelegate?
    
    public func activateReminder(request: MRTReminderRequest) {
        guard CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) else { return }
        
        notificationCenter.delegate = self
        locationManager.delegate = self
        
        currentRequest = request
        let nextIsRight = request.isDirectionToTheRight
        
        var currIndex = 0
        var currStation = request.startStation
        
        if let prevStation = request.startStation.getPrevStation(nextIsRight: nextIsRight) {
            currIndex = -1
            currStation = prevStation
        }
        
        while true {
            locationManager.startMonitoring(for: currStation.region)
            regionIndex[currStation.region] = currIndex
            if currStation === request.endStation {
                break
            }
            if let nextStation = currStation.getNextStation(nextIsRight: nextIsRight) {
                currIndex += 1
                currStation = nextStation
            }
        }
        
        if let nextStation = currStation.getNextStation(nextIsRight: nextIsRight) {
            locationManager.startMonitoring(for: nextStation.region)
            regionIndex[nextStation.region] = (currIndex + 1)
        }
        
        print("Monitoring Started For \(regionIndex.count) Regions")
    }
    
    public func deactivateReminder() {
        print("Monitoring Ended For \(locationManager.monitoredRegions.count) Regions")
        
        for region in regionIndex.keys {
            locationManager.stopMonitoring(for: region)
        }
        regionIndex.removeAll()
        currentRequest = nil
        
        showNonHapticNotification(title: "Your journey is done!",
                                  body: "Thank you for commuting with MRT Jakarta.")
    }
    
    public func showNotification(title: String, body: String) {
        guard isReminderEnabled else { return }
        
        notificationCenter.getNotificationSettings() { settings in
            if settings.authorizationStatus == .authorized {
                self.createNotification(title: title, body: body)
            }
        }
    }
    public func showNonHapticNotification(title: String, body: String) {
        passiveNotification = true
        showNotification(title: title, body: body)
    }
    private func createNotification(title: String, body: String) {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = title
        notificationContent.body = body
        
        if isSoundEnabled { notificationContent.sound = .default }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
        
        let notifRequest = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: notificationContent,
            trigger: trigger)
        
        notificationCenter.add(notifRequest) { error in
            if error != nil {
                print("Error: \(String(describing: error))")
            }
            else {
                print("Notification Shown")
            }
        }
    }
}

extension MRTReminderCenter: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Notification Dismissed")
        completionHandler()
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Notification Shown On App")
        if isHapticEnabled && !passiveNotification {
            MRTReminderHaptics.shared.playVibration(duration: 0.5, delay: 0.5, repetition: 3)
            completionHandler(.banner)
        }
        else {
            passiveNotification = false
            completionHandler([.banner, .sound])
        }
    }
}

extension MRTReminderCenter: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        guard region is CLCircularRegion else { return }
        guard let stationIndex = regionIndex[region] else { return }
        guard currentRequest.currStationIndex != stationIndex else { return }
        
        print("User entered a station: \(stationIndex)")
        self.currentRequest.updateCurrentStatus(currStationIndex: stationIndex)
        self.progressDelegate?.reminderProgressUpdated(currentStationIndex: currentRequest.currStationIndex,
                                               lastStationIndex: currentRequest.lastStationIndex,
                                               stationsRemaining: currentRequest.stationsRemaining)
        
        if currentRequest.stationsRemaining == 1 {
            showNotification(title: "You almost arrive!",
                             body: "You have 1 station left. Get ready to get off!")
        }
        else if currentRequest.stationsRemaining == 0 {
            showNotification(title: "You’ve arrived!",
                             body: "Get off at \(currentRequest.endStation.name) station now.")
        }
        else if currentRequest.currStationIndex > currentRequest.lastStationIndex {
            showNotification(title: "You missed your destination!",
                             body: "Get off the station now & change your train lane.")
        }
        else if currentRequest.currStationIndex < 0 {
            showNotification(title: "Your train is heading the wrong way!",
                             body: "Get off the station now & change your train lane.")
        }
    }
}
