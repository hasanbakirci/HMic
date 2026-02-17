import Foundation
import CoreAudio
import Combine
import AVFoundation

class MicrophoneService: ObservableObject {
    static let shared = MicrophoneService()
    
    @Published var currentInputGain: Float = 0.0
    @Published var isMuted: Bool = false
    @Published var deviceName: String = "Unknown Mic"
    @Published var currentAudioLevel: Float = 0.0  // Real-time audio level (0.0-1.0)
    
    private let audioService = AudioDeviceService.shared
    let audioLevelMonitor = AudioLevelMonitor()  // Exposed for UI binding
    private var currentDeviceID: AudioObjectID?
    private var deviceMonitor: AudioDeviceMonitor?
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        setupMonitoring()
        setupLevelMonitoring()
    }
    
    private func setupLevelMonitoring() {
        // Bind audio level monitor to published property
        audioLevelMonitor.$currentLevel
            .receive(on: RunLoop.main)
            .assign(to: \.currentAudioLevel, on: self)
            .store(in: &cancellables)
        
        // Note: start() is called manually from UI when needed
    }
    
    func setupMonitoring() {
        refreshState()
        setupPropertyListeners()
    }
    
    private func setupPropertyListeners() {
        guard let deviceID = currentDeviceID else { return }
        
        // Remove old listeners
        deviceMonitor?.removeAllListeners()
        
        // Create new monitor
        let monitor = AudioDeviceMonitor(deviceID: deviceID)
        
        // Listen for volume changes
        monitor.addListener(
            property: kAudioDevicePropertyVolumeScalar,
            scope: kAudioDevicePropertyScopeInput,
            element: kAudioObjectPropertyElementMain
        ) { [weak self] in
            self?.refreshGain()
        }
        
        // Try InputGainScalar as well (some devices use this)
        monitor.addListener(
            property: kAudioDevicePropertyInputGainScalar,
            scope: kAudioDevicePropertyScopeInput,
            element: kAudioObjectPropertyElementMain
        ) { [weak self] in
            self?.refreshGain()
        }
        
        // Listen for mute changes
        monitor.addListener(
            property: kAudioDevicePropertyMute,
            scope: kAudioDevicePropertyScopeInput,
            element: kAudioObjectPropertyElementMain
        ) { [weak self] in
            self?.refreshMuteState()
        }
        
        self.deviceMonitor = monitor
    }
    
    func refreshState() {
        guard let deviceID = audioService.getDefaultInputDeviceID() else {
            DispatchQueue.main.async {
                self.deviceName = "No Input Device"
            }
            return
        }
        
        if currentDeviceID != deviceID {
            currentDeviceID = deviceID
            updateDeviceName(deviceID: deviceID)
            setupPropertyListeners()
        }
        
        refreshGain()
        refreshMuteState()
    }
    
    private func refreshGain() {
        guard let deviceID = currentDeviceID else { return }
        let gain = audioService.getInputGain(deviceID: deviceID)
        
        DispatchQueue.main.async {
            if abs(self.currentInputGain - gain) > 0.01 {
                self.currentInputGain = gain
            }
        }
    }
    
    private func refreshMuteState() {
        guard let deviceID = currentDeviceID else { return }
        let muted = audioService.isMuted(deviceID: deviceID)
        
        DispatchQueue.main.async {
            if self.isMuted != muted {
                self.isMuted = muted
            }
        }
    }
    
    private func updateDeviceName(deviceID: AudioObjectID) {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioObjectPropertyName,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        var size = UInt32(MemoryLayout<CFString>.size)
        var deviceNameRef: CFString? = nil
        
        let status = withUnsafeMutablePointer(to: &deviceNameRef) { ptr in
            AudioObjectGetPropertyData(
                deviceID,
                &propertyAddress,
                0,
                nil,
                &size,
                ptr
            )
        }
        
        if status == noErr, let retrievedName = deviceNameRef {
            DispatchQueue.main.async {
                self.deviceName = retrievedName as String
            }
        }
    }
    
    // MARK: - Actions
    
    func setGain(_ gain: Float) {
        guard let deviceID = currentDeviceID else { return }
        audioService.setInputGain(deviceID: deviceID, gain: gain)
        // Event listener will update the state automatically
    }
    
    func toggleMute() {
        guard let deviceID = currentDeviceID else { return }
        let newState = !isMuted
        audioService.setMute(deviceID: deviceID, mute: newState)
        // Event listener will update the state automatically
    }
    
    func setMute(_ mute: Bool) {
        guard let deviceID = currentDeviceID else { return }
        audioService.setMute(deviceID: deviceID, mute: mute)
        // Event listener will update the state automatically
    }
    
    func requestAccess() {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized:
            break
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                if granted {
                    self.refreshState()
                }
            }
        case .denied, .restricted:
            // Handle denied state if needed
            break
        @unknown default:
            break
        }
    }
    
    deinit {
        deviceMonitor?.removeAllListeners()
    }
}
