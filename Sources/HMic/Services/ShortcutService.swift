import Foundation
import Carbon

enum ShortcutAction: String, CaseIterable, Codable {
    case toggleMute = "Toggle Mute"
    case increaseGain = "Increase Gain"
    case decreaseGain = "Decrease Gain"
}

struct SavedShortcut: Codable, Equatable {
    let keyCode: UInt32
    let modifiers: UInt32
}

class ShortcutService: ObservableObject {
    static let shared = ShortcutService()
    
    @Published var shortcuts: [ShortcutAction: SavedShortcut] = [:]
    
    private let defaults = UserDefaults.standard
    private let hotkeyManager = GlobalHotkeyManager.shared
    private var registeredIDs: [ShortcutAction: UInt32] = [:]
    
    private init() {
        loadShortcuts()
        registerAll()
    }
    
    func loadShortcuts() {
        for action in ShortcutAction.allCases {
            if let data = defaults.data(forKey: "shortcut_\(action.rawValue)"),
               let shortcut = try? JSONDecoder().decode(SavedShortcut.self, from: data) {
                shortcuts[action] = shortcut
            }
        }
    }
    
    func saveShortcut(action: ShortcutAction, keyCode: UInt32, modifiers: UInt32) {
        let shortcut = SavedShortcut(keyCode: keyCode, modifiers: modifiers)
        shortcuts[action] = shortcut
        
        if let data = try? JSONEncoder().encode(shortcut) {
            defaults.set(data, forKey: "shortcut_\(action.rawValue)")
        }
        
        registerAll()
    }
    
    func removeShortcut(action: ShortcutAction) {
        shortcuts.removeValue(forKey: action)
        defaults.removeObject(forKey: "shortcut_\(action.rawValue)")
        registerAll()
    }
    
    func registerAll() {
        // Unregister all existing
        for (_, id) in registeredIDs {
            hotkeyManager.unregisterHotKey(id: id)
        }
        registeredIDs.removeAll()
        
        // Register new ones
        for (action, shortcut) in shortcuts {
            if let id = hotkeyManager.registerHotKey(
                keyCode: shortcut.keyCode,
                modifiers: shortcut.modifiers,
                action: { [weak self] in
                    self?.performAction(action)
                }
            ) {
                registeredIDs[action] = id
            }
        }
    }
    
    private func performAction(_ action: ShortcutAction) {
        let micService = MicrophoneService.shared
        
        switch action {
        case .toggleMute:
            micService.toggleMute()
        case .increaseGain:
            let newGain = min(micService.currentInputGain + 0.1, 1.0)
            micService.setGain(newGain)
        case .decreaseGain:
            let newGain = max(micService.currentInputGain - 0.1, 0.0)
            micService.setGain(newGain)
        }
    }
}
