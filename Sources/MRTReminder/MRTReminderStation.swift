//
//  MRTReminderStation.swift
//  
//
//  Created by Muhammad Fauzul Akbar on 21/07/23.
//

import CoreLocation

public class MRTReminderStation {
    public private(set) var name: String
    public private(set) var coordinate = CLLocationCoordinate2D()
    public private(set) var leftStation, rightStation: MRTReminderStation?
    
    init(name: String, latitude: Double, longitude: Double) {
        self.name = name
        self.coordinate.latitude = latitude
        self.coordinate.longitude = longitude
    }
    
    public func setLeftStation(_ station: MRTReminderStation) {
        leftStation = station
    }
    public func setRightStation(_ station: MRTReminderStation) {
        rightStation = station
    }
    
    public lazy var region = makeRegion()
    private func makeRegion() -> CLCircularRegion {
        let region = CLCircularRegion(
            center: coordinate,
            radius: MRTReminderCenter.shared.reminderRadius,
            identifier: UUID().uuidString)
        region.notifyOnEntry = true
        return region
    }
    
    public func getNextStation(right: Bool) -> MRTReminderStation? {
        if right {
            return rightStation
        }
        else {
            return leftStation
        }
    }
}
