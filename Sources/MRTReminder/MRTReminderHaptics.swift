//
//  MRTReminderHaptics.swift
//  
//
//  Created by Ardli Fadhillah on 21/07/23.
//

import CoreHaptics

public class MRTReminderHaptics {
    public static let shared = MRTReminderHaptics()
    
    func createHapticEngine() -> CHHapticEngine? {
        do {
            return try CHHapticEngine()
        } catch {
            print("Error creating haptic engine: \(error)")
            return nil
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
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            print("Haptics not supported on this device.")
            return
        }

        guard let hapticEngine = createHapticEngine() else { return }
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 5.0)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 5.0)
        let continuousEvent = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity, sharpness], relativeTime: 0, duration: duration)
        
        do {
            let pattern = try CHHapticPattern(events: [continuousEvent], parameters: [])
            let patternPlayer = try hapticEngine.makePlayer(with: pattern)
            try hapticEngine.start()
            try patternPlayer.start(atTime: 0)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                do {
                    try patternPlayer.stop(atTime: 0)
                    hapticEngine.stop()
                } catch let error {
                    print("Error stopping continuous vibration: \(error)")
                }
            }
        } catch let error {
            print("Error playing continuous vibration: \(error)")
        }
    }
}
