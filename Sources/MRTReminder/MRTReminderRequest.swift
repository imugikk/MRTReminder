//
//  MRTReminderRequest.swift
//
//
//  Created by Ardli Fadhillah on 18/07/23.
//

import CoreLocation
import UserNotifications

public class MRTReminderRequest {
    public private(set) var destinationStation: Station
    public private(set) var reminderRadius: Double
    
    public init(destinationStation: Station, reminderRadius: Double = 2) {
        self.destinationStation = destinationStation
        self.reminderRadius = reminderRadius
    }
    
    public func changeDestination(station: Station) {
        self.destinationStation = station
    }
    
    public func setReminderRadius(to radius: Double) {
        self.reminderRadius = radius
    }
    
    public private(set) lazy var destinationLocation = createDestination()
    
    private func createDestination() -> CLCircularRegion {
        let region = CLCircularRegion(
            center: destinationStation.coordinate,
            radius: reminderRadius,
            identifier: UUID().uuidString)
        region.notifyOnEntry = true
        return region
    }
}
