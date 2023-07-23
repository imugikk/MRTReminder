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
    public private(set) var currStationIndex = 0 {
        didSet {
            guard currStationIndex != oldValue else { return }
            prevStationIndex = oldValue
        }
    }
    public private(set) var currentStation: MRTReminderStation!
    public private(set) var prevStationIndex = 0
    
    public var stationsRemaining: Int {
        lastStationIndex - currStationIndex
    }
    public var stationCount: Int {
        lastStationIndex
    }
    
    public var stationCountIncludingNeighbors: Int {
        lastStationIndex + getExtraNeighboringStationCount()
    }
    public var estimatedTimeArrival: Double {
        MRTReminderCenter.shared.averageDurationPerStation * Double(stationCount)
    }
    
    public init(startingStation: MRTReminderStation, destinationStation: MRTReminderStation) {
        self.startStation = startingStation
        self.currentStation = startingStation
        self.endStation = destinationStation
        setDestination(station: destinationStation)
    }
    
    public func setDestination(station: MRTReminderStation) {
        self.endStation = station
        isDirectionToTheRight = getJourneyDirection()
        lastStationIndex = getIndexOfLastStation()
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
    
    internal func updateCurrentStatus(currStationIndex: Int) {
        self.currStationIndex = currStationIndex
        
        let offset = currStationIndex - prevStationIndex
        for _ in 0..<abs(offset) {
            if offset > 0, let nextStation = currentStation.getNextStation(nextIsRight: isDirectionToTheRight) {
                currentStation = nextStation
            }
            else if offset < 0, let prevStation = currentStation.getPrevStation(nextIsRight: isDirectionToTheRight) {
                currentStation = prevStation
            }
        }
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
