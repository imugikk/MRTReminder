//
//  File.swift
//  
//
//  Created by Muhammad Fauzul Akbar on 21/07/23.
//

import Foundation
import CoreLocation

class MRTReminderStation {
    public static let shared = MRTReminderStation()
    private init() { }
    
    public private(set) var listStations: [String: Station] = [:]
    
    public func register(stations: [(String, CLLocationCoordinate2D)]) {
        var prevStation = Station(name: stations[0].0, coordinate: stations[0].1)
        listStations[stations[0].0] = prevStation
        for i in 1..<stations.count {
            var currentStation = Station(name: stations[i].0, coordinate: stations[i].1)
            currentStation.left = prevStation
            prevStation.right = currentStation
            listStations[stations[i].0] = currentStation
            prevStation = currentStation
        }
    }
}

