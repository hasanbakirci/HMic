import Foundation
import CoreAudio

enum AudioDeviceError: Error {
    case deviceNotFound
    case propertyNotFound
    case operationFailed
}

class AudioDeviceService {
    static let shared = AudioDeviceService()
    
    private init() {}
    
    // MARK: - Device Discovery
    
    func getDefaultInputDeviceID() -> AudioObjectID? {
        var deviceID = kAudioObjectUnknown
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultInputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        var size = UInt32(MemoryLayout<AudioObjectID>.size)
        let status = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            &size,
            &deviceID
        )
        
        return status == noErr ? deviceID : nil
    }
    
    // MARK: - Volume Control
    
    func getInputGain(deviceID: AudioObjectID) -> Float {
        var gain: Float = 0.0
        // Try Input Gain first, then Volume
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyInputGainScalar,
            mScope: kAudioDevicePropertyScopeInput,
            mElement: kAudioObjectPropertyElementMain
        )
        
        if !hasProperty(deviceID: deviceID, address: &propertyAddress) {
            propertyAddress.mElement = 1
            if !hasProperty(deviceID: deviceID, address: &propertyAddress) {
                // Fallback to VolumeScalar
                propertyAddress.mSelector = kAudioDevicePropertyVolumeScalar
                propertyAddress.mElement = kAudioObjectPropertyElementMain
                if !hasProperty(deviceID: deviceID, address: &propertyAddress) {
                    propertyAddress.mElement = 1
                }
            }
        }
        
        var size = UInt32(MemoryLayout<Float>.size)
        let status = AudioObjectGetPropertyData(
            deviceID,
            &propertyAddress,
            0,
            nil,
            &size,
            &gain
        )
        
        return status == noErr ? gain : 0.0
    }
    
    func setInputGain(deviceID: AudioObjectID, gain: Float) {
        var newGain = min(max(gain, 0.0), 1.0)
        
        // Determine which property to use (same logic as get)
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyInputGainScalar,
            mScope: kAudioDevicePropertyScopeInput,
            mElement: kAudioObjectPropertyElementMain
        )
        
        if !hasProperty(deviceID: deviceID, address: &propertyAddress) {
            propertyAddress.mElement = 1
            if !hasProperty(deviceID: deviceID, address: &propertyAddress) {
                propertyAddress.mSelector = kAudioDevicePropertyVolumeScalar
                propertyAddress.mElement = kAudioObjectPropertyElementMain
                if !hasProperty(deviceID: deviceID, address: &propertyAddress) {
                    propertyAddress.mElement = 1
                }
            }
        }
        
        let size = UInt32(MemoryLayout<Float>.size)
        let status = AudioObjectSetPropertyData(
            deviceID,
            &propertyAddress,
            0,
            nil,
            size,
            &newGain
        )
        
        if status != noErr {
            print("Error setting gain: \(status)")
        }
    }
    
    // MARK: - Mute Control
    
    func isMuted(deviceID: AudioObjectID) -> Bool {
        var muted: UInt32 = 0
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyMute,
            mScope: kAudioDevicePropertyScopeInput,
            mElement: kAudioObjectPropertyElementMain
        )
        
        if !hasProperty(deviceID: deviceID, address: &propertyAddress) {
            propertyAddress.mElement = 1
        }
        
        var size = UInt32(MemoryLayout<UInt32>.size)
        let status = AudioObjectGetPropertyData(
            deviceID,
            &propertyAddress,
            0,
            nil,
            &size,
            &muted
        )
        
        return status == noErr && muted == 1
    }
    
    func setMute(deviceID: AudioObjectID, mute: Bool) {
        var muteVal: UInt32 = mute ? 1 : 0
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyMute,
            mScope: kAudioDevicePropertyScopeInput,
            mElement: kAudioObjectPropertyElementMain
        )
        
        if !hasProperty(deviceID: deviceID, address: &propertyAddress) {
            propertyAddress.mElement = 1
        }
        
        let size = UInt32(MemoryLayout<UInt32>.size)
        AudioObjectSetPropertyData(
            deviceID,
            &propertyAddress,
            0,
            nil,
            size,
            &muteVal
        )
    }
    
    // MARK: - Helpers
    
    private func hasProperty(deviceID: AudioObjectID, address: inout AudioObjectPropertyAddress) -> Bool {
        return AudioObjectHasProperty(deviceID, &address)
    }
}
