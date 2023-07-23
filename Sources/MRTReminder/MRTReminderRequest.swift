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
    public private(set) var lastStationIndex = 0
    public private(set) var currStationIndex = 0
    public private(set) var stationsRemaining = 0
    public private(set) var stationCount = 0
    public private(set) var stationCountIncludingNeighbors = 0
    public private(set) var estimatedTimeOfArrival = 0.0
    
    public init(startingStation: MRTReminderStation, destinationStation: MRTReminderStation) {
        self.startStation = startingStation
        self.endStation = destinationStation
        setDestination(station: destinationStation)
    }
    
    public func setDestination(station: MRTReminderStation) {
        self.endStation = station
        isDirectionToTheRight = getJourneyDirection()
        lastStationIndex = getIndexOfLastStation()
        stationsRemaining = lastStationIndex
        stationCount = lastStationIndex
        stationCountIncludingNeighbors = lastStationIndex + getExtraNeighboringStationCount()
        estimatedTimeOfArrival = MRTReminderCenter.shared.averageTravelDurationPerStation * Double(stationCount)
    }
    
    private func getJourneyDirection() -> Bool {
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
    private func getIndexOfLastStation() -> Int {
        var total = 0
        var currStation = startStation
        while let nextStation = currStation.getNextStation(nextIsRight: isDirectionToTheRight) {
            total += 1
            if nextStation === endStation {
                break
            }
            currStation = nextStation
        }
        return total
    }
    
    public func updateCurrentStatus(currStationIndex: Int) {
        self.currStationIndex = currStationIndex
        self.stationsRemaining = lastStationIndex - currStationIndex
    }
    
    private func getExtraNeighboringStationCount() -> Int {
        var extraStation = 0
        if startStationHasPreviousStation() { extraStation += 1 }
        if endStationHasNextStation() { extraStation += 1 }
        return extraStation
    }
    public func startStationHasPreviousStation() -> Bool {
        return startStation.getPrevStation(nextIsRight: isDirectionToTheRight) != nil
    }
    public func endStationHasNextStation() -> Bool {
        return endStation.getNextStation(nextIsRight: isDirectionToTheRight) != nil
    }
}
