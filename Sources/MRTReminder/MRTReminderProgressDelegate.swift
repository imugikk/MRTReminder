//
//  MRTReminderProgressDelegate.swift
//  
//
//  Created by Ardli Fadhillah on 22/07/23.
//

import Foundation

public protocol MRTReminderProgressDelegate {
    func reminderProgressUpdated(currentStationIndex: Int, lastStationIndex: Int, stationsRemaining: Int)
}
