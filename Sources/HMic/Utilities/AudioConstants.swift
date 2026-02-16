import Foundation
import CoreAudio

// MARK: - Audio Property Selectors

/// Property selector for input gain (volume)
let kAudioDevicePropertyInputGainScalar: AudioObjectPropertySelector = 0x696e676e // 'ingn'

/// Property selector for device volume
let kAudioDevicePropertyVolumeScalar: AudioObjectPropertySelector = 0x766f6c6d // 'volm'

// MARK: - Gain/dB Conversion

extension Float {
    /// Convert linear gain (0.0-1.0) to decibels
    func toDecibels() -> Float {
        if self <= 0.0 {
            return -96.0 // Represent silence as -96dB
        }
        return 20.0 * log10(self)
    }
    
    /// Convert decibels to linear gain (0.0-1.0)
    static func fromDecibels(_ db: Float) -> Float {
        if db <= -96.0 {
            return 0.0
        }
        return pow(10.0, db / 20.0)
    }
    
    /// Format as percentage string
    func toPercentageString() -> String {
        return "\(Int(self * 100))%"
    }
    
    /// Format as decibels string
    func toDecibelsString() -> String {
        let db = toDecibels()
        return String(format: "%.1f dB", db)
    }
}
