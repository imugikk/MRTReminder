//
//  MRTReminderRequest.swift
//
//
//  Created by Ardli Fadhillah on 18/07/23.
//

import CoreLocation
import UserNotifications

public class MRTReminderRequest {
    public private(set) var destinationName: String
    private var destinationCoordinate = CLLocationCoordinate2D()
    public private(set) var reminderRadius: Double
    
    public init(destinationName: String, destinationCoordinate: (latitude: Double, longitude: Double), reminderRadius: Double = 2) {
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
    
    public func setReminderRadius(to radius: Double) {
        self.reminderRadius = radius
    }
    
    public private(set) lazy var destinationLocation = createDestination()
    private func createDestination() -> CLCircularRegion {
        let region = CLCircularRegion(
            center: destinationCoordinate,
            radius: reminderRadius,
            identifier: UUID().uuidString)
        region.notifyOnEntry = true
        return region
    }
}
