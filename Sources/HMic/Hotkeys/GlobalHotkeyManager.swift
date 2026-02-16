import Foundation
import Carbon

// MARK: - HotKey Types

struct HotKey {
    let id: UInt32
    let keyCode: UInt32
    let modifiers: UInt32
    let action: () -> Void
}

class GlobalHotkeyManager {
    static let shared = GlobalHotkeyManager()
    
    private var hotKeys: [UInt32: HotKey] = [:]
    private var carbonRefs: [UInt32: EventHotKeyRef] = [:]
    private var eventHandlerRef: EventHandlerRef?
    private var currentId: UInt32 = 1
    
    private init() {
        installEventHandler()
    }
    
    private func installEventHandler() {
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )
        
        let handler: EventHandlerUPP = { (_, event, _) -> OSStatus in
            var hotKeyID = EventHotKeyID()
            let status = GetEventParameter(
                event,
                EventParamName(kEventParamDirectObject),
                EventParamType(typeEventHotKeyID),
                nil,
                MemoryLayout<EventHotKeyID>.size,
                nil,
                &hotKeyID
            )
            
            if status == noErr {
                GlobalHotkeyManager.shared.handleHotKey(id: hotKeyID.id)
            }
            
            return noErr
        }
        
        InstallEventHandler(
            GetApplicationEventTarget(),
            handler,
            1,
            &eventType,
            nil,
            &eventHandlerRef
        )
    }
    
    func handleHotKey(id: UInt32) {
        if let hotKey = hotKeys[id] {
            hotKey.action()
        }
    }
    
    @discardableResult
    func registerHotKey(keyCode: UInt32, modifiers: UInt32, action: @escaping () -> Void) -> UInt32? {
        let id = currentId
        currentId += 1
        
        let hotKeyID = EventHotKeyID(signature: OSType(0x484D4943), id: id) // HMIC
        var carbonHotKey: EventHotKeyRef?
        
        let status = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &carbonHotKey
        )
        
        if status == noErr {
            let hotKey = HotKey(id: id, keyCode: keyCode, modifiers: modifiers, action: action)
            hotKeys[id] = hotKey
            if let ref = carbonHotKey {
                carbonRefs[id] = ref
            }
            return id
        } else {
            print("Failed to register hotkey: \(status)")
            return nil
        }
    }
    
    func unregisterHotKey(id: UInt32) {
        if let ref = carbonRefs[id] {
            UnregisterEventHotKey(ref)
            carbonRefs.removeValue(forKey: id)
        }
        hotKeys.removeValue(forKey: id)
    }
    
    func unregisterAll() {
        for (id, ref) in carbonRefs {
            UnregisterEventHotKey(ref)
        }
        carbonRefs.removeAll()
        hotKeys.removeAll()
    }
    
    deinit {
        unregisterAll()
        if let handler = eventHandlerRef {
            RemoveEventHandler(handler)
        }
    }
}
