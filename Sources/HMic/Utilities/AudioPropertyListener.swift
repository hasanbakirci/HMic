import Foundation
import CoreAudio

/// Wrapper for CoreAudio property listeners to handle real-time audio device changes
class AudioPropertyListener {
    typealias PropertyChangeCallback = () -> Void
    
    private var deviceID: AudioObjectID
    private var propertyAddress: AudioObjectPropertyAddress
    private var callback: PropertyChangeCallback
    private var listenerBlock: AudioObjectPropertyListenerBlock?
    
    init(deviceID: AudioObjectID, 
         property: AudioObjectPropertySelector,
         scope: AudioObjectPropertyScope = kAudioObjectPropertyScopeGlobal,
         element: AudioObjectPropertyElement = kAudioObjectPropertyElementMain,
         callback: @escaping PropertyChangeCallback) {
        
        self.deviceID = deviceID
        self.propertyAddress = AudioObjectPropertyAddress(
            mSelector: property,
            mScope: scope,
            mElement: element
        )
        self.callback = callback
        
        setupListener()
    }
    
    private func setupListener() {
        listenerBlock = { [weak self] (numberAddresses, addresses) in
            guard let self = self else { return }
            
            // Execute callback on main thread
            DispatchQueue.main.async {
                self.callback()
            }
        }
        
        if let block = listenerBlock {
            let status = AudioObjectAddPropertyListenerBlock(
                deviceID,
                &propertyAddress,
                DispatchQueue.global(qos: .userInitiated),
                block
            )
            
            if status != noErr {
                print("⚠️ Failed to add property listener: \(status)")
            }
        }
    }
    
    func removeListener() {
        if let block = listenerBlock {
            var address = propertyAddress
            AudioObjectRemovePropertyListenerBlock(
                deviceID,
                &address,
                DispatchQueue.global(qos: .userInitiated),
                block
            )
            listenerBlock = nil
        }
    }
    
    deinit {
        removeListener()
    }
}

/// Manages multiple property listeners for audio device monitoring
class AudioDeviceMonitor {
    private var listeners: [AudioPropertyListener] = []
    private let deviceID: AudioObjectID
    
    init(deviceID: AudioObjectID) {
        self.deviceID = deviceID
    }
    
    func addListener(property: AudioObjectPropertySelector,
                    scope: AudioObjectPropertyScope = kAudioObjectPropertyScopeGlobal,
                    element: AudioObjectPropertyElement = kAudioObjectPropertyElementMain,
                    callback: @escaping () -> Void) {
        
        let listener = AudioPropertyListener(
            deviceID: deviceID,
            property: property,
            scope: scope,
            element: element,
            callback: callback
        )
        listeners.append(listener)
    }
    
    func removeAllListeners() {
        listeners.forEach { $0.removeListener() }
        listeners.removeAll()
    }
    
    deinit {
        removeAllListeners()
    }
}
