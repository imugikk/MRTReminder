//
//  MRTReminderRequest.swift
//
//
//  Created by Ardli Fadhillah on 18/07/23.
//

import CoreLocation
import UserNotifications

public class MRTReminderRequest {
    public private(set) var startStation: MRTReminderStation
    public private(set) var endStation: MRTReminderStation
    
    public private(set) var isDirectionToTheRight = false
    public private(set) var stationCount = 0
    public private(set) var stationsTraveled = 0
    public private(set) var stationsRemaining = 0
    
    public var currentStation: MRTReminderStation
    
    public init(startingStation: MRTReminderStation, destinationStation: MRTReminderStation) {
        self.startStation = startingStation
        self.endStation = destinationStation
        
        currentStation = startStation
        isDirectionToTheRight = calculateDirection()
        stationCount = calculateStationCount()
        stationsRemaining = stationCount
    }
    
    public func setDestination(station: MRTReminderStation) {
        self.endStation = station
        
        isDirectionToTheRight = calculateDirection()
        stationCount = calculateStationCount()
        stationsRemaining = stationCount
    }
    
    private func calculateDirection() -> Bool {
        var right = false
        var currStation = startStation
        while let nextStation = currStation.rightStation {
            if nextStation === endStation {
                right = true
                break
            }
            currStation = nextStation
        }
        return right
    }
    private func calculateStationCount() -> Int {
        var total = 0
        var currStation = startStation
        while let nextStation = currStation.getNextStation(right: isDirectionToTheRight) {
            total += 1
            if nextStation === endStation {
                break
            }
            currStation = nextStation
        }
        return total
    }
    public func getNextStation() -> MRTReminderStation? {
        return currentStation.getNextStation(right: isDirectionToTheRight)
    }
    public func updateCurrentStatus() {
        stationsTraveled += 1
        stationsRemaining -= 1
        
        if let nextStation = getNextStation() {
            currentStation = nextStation
        }
    }
}
