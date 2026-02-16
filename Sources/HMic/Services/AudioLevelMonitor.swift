import Foundation
import AVFoundation
import Combine

class AudioLevelMonitor: ObservableObject {
    @Published var currentLevel: Float = 0.0  // 0.0 to 1.0, normalized
    @Published var peakLevel: Float = 0.0
    
    private let audioEngine = AVAudioEngine()
    private var timer: Timer?
    private var isRunning = false
    
    init() {
        setupAudioEngine()
    }
    
    private func setupAudioEngine() {
        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        
        // Install tap to monitor audio levels
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            self?.processAudioBuffer(buffer)
        }
    }
    
    func start() {
        guard !isRunning else { return }
        
        do {
            try audioEngine.start()
            isRunning = true
            
            // Reset peak every 1 second
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                DispatchQueue.main.async {
                    self?.peakLevel = 0.0
                }
            }
        } catch {
            print("❌ Failed to start audio engine: \(error)")
        }
    }
    
    func stop() {
        guard isRunning else { return }
        
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        timer?.invalidate()
        timer = nil
        isRunning = false
        
        DispatchQueue.main.async {
            self.currentLevel = 0.0
            self.peakLevel = 0.0
        }
    }
    
    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData else { return }
        
        let channelDataValue = channelData[0]
        let frames = buffer.frameLength
        
        // Calculate RMS (Root Mean Square) for average level
        var sum: Float = 0.0
        var peak: Float = 0.0
        
        for i in 0..<Int(frames) {
            let sample = channelDataValue[i]
            sum += sample * sample
            peak = max(peak, abs(sample))
        }
        
        let rms = sqrt(sum / Float(frames))
        
        // Convert to dB and normalize to 0.0-1.0 range
        // -60 dB to 0 dB range
        let db = 20 * log10(max(rms, 0.00001))  // Avoid log(0)
        let normalizedLevel = max(0.0, min(1.0, (db + 60.0) / 60.0))
        
        let normalizedPeak = max(0.0, min(1.0, (20 * log10(max(peak, 0.00001)) + 60.0) / 60.0))
        
        DispatchQueue.main.async {
            // Smooth the level changes
            self.currentLevel = self.currentLevel * 0.7 + normalizedLevel * 0.3
            self.peakLevel = max(self.peakLevel, normalizedPeak)
        }
    }
    
    deinit {
        stop()
    }
}
