//
//  MRTReminderStationList.swift
//  
//
//  Created by Muhammad Fauzul Akbar on 21/07/23.
//

import CoreLocation

class MRTReminderStationList {
    public static let shared = MRTReminderStationList()
    private init() { }
    
    private var stationList = [String: MRTReminderStation]()
    
    public func register(stations: [MRTReminderStation]) {
        var currStation = stations[0]
        stationList[currStation.name] = currStation
        for i in 1..<stations.count {
            let nextStation = stations[i]
            nextStation.setLeftStation(currStation)
            currStation.setRightStation(nextStation)
            stationList[nextStation.name] = nextStation
            currStation = nextStation
        }
    }
    
    public func getStation(withName name: String) -> MRTReminderStation? {
        return stationList[name]
    }
}
