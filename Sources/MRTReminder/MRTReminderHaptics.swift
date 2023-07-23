//
//  MRTReminderHaptics.swift
//  
//
//  Created by Ardli Fadhillah on 21/07/23.
//

import CoreHaptics
import UIKit

public class MRTReminderHaptics {
    public static let shared = MRTReminderHaptics()
    private var engine: CHHapticEngine?
    
    private init() {
        engine = createHapticEngine()
        observeAppBackgroundNotification()
    }
    
    private func createHapticEngine() -> CHHapticEngine? {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return nil }
        
        do {
            return try CHHapticEngine()
        } catch let error {
            print("Error creating haptic engine: \(error)")
            return nil
        }
    }
    
    private func observeAppBackgroundNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    @objc private func appDidEnterBackground() {
        if engine != nil { engine!.stop() }
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
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        guard let engine = self.engine else { return }
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 5.0)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 5.0)
        let continuousEvent = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity, sharpness], relativeTime: 0, duration: duration)
        
        do {
            try engine.start()
            let pattern = try CHHapticPattern(events: [continuousEvent], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
            
            engine.notifyWhenPlayersFinished { _ in
                return .stopEngine
            }
        } catch let error {
            print("Error playing continuous vibration: \(error)")
        }
    }
}
