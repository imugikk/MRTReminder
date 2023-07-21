//
//  MRTReminderHaptics.swift
//  
//
//  Created by Ardli Fadhillah on 21/07/23.
//

import CoreHaptics

public class MRTReminderHaptics {
    
    public static let shared = MRTReminderHaptics()
    
    private var hapticEngine: CHHapticEngine?
    
    private init() {
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
        } catch let error {
            print("Error creating haptic engine: \(error)")
        }
    }
    
    public func playVibration(duration: TimeInterval, delay: TimeInterval, repetition: Int) {
        var repeatCount = repetition
        var delayTime: TimeInterval = 0
        
        while repeatCount > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + delayTime) {
                self.playContinuousVibration(duration: duration)
            }
            
            repeatCount -= 1
            delayTime += delay + duration
        }
    }
    
    private func playContinuousVibration(duration: TimeInterval) {
        guard let hapticEngine = hapticEngine else { return }
        
        // Define the continuous haptic event
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 5.0)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 5.0)
        let continuousEvent = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity, sharpness], relativeTime: 0, duration: duration)
        
        do {
            // Create a pattern with the continuous haptic event
            let pattern = try CHHapticPattern(events: [continuousEvent], parameters: [])
            
            // Create the haptic advanced pattern player
            let patternPlayer = try hapticEngine.makeAdvancedPlayer(with: pattern)
            
            // Enable looping for continuous vibration
            patternPlayer.loopEnabled = true
            
            // Start the continuous haptic feedback
            try patternPlayer.start(atTime: 0)
            
            // Stop the haptic feedback after the desired duration (1 second)
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                do {
                    try patternPlayer.stop(atTime: CHHapticTimeImmediate)
                } catch let error {
                    print("Error stopping continuous vibration: \(error)")
                }
            }
        } catch let error {
            print("Error playing continuous vibration: \(error)")
        }
    }
}
