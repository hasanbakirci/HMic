import Cocoa
import SwiftUI
import Combine

class StatusBarController {
    private var statusItem: NSStatusItem
    private var popover: NSPopover
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        popover = NSPopover()
        
        setupPopover()
        setupStatusItem()
        setupBindings()
    }
    
    private func setupPopover() {
        popover.contentSize = NSSize(width: 280, height: 350)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: MenuBarView())
    }
    
    private func setupStatusItem() {
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "mic.fill", accessibilityDescription: "Mic Control")
            button.action = #selector(togglePopover(_:))
            button.target = self
        }
    }
    
    private func setupBindings() {
        MicrophoneService.shared.$isMuted
            .receive(on: RunLoop.main)
            .sink { [weak self] isMuted in
                self?.updateIcon(isMuted: isMuted)
            }
            .store(in: &cancellables)
    }
    
    private func updateIcon(isMuted: Bool) {
        if let button = statusItem.button {
            let imageName = isMuted ? "mic.slash.fill" : "mic.fill"
            button.image = NSImage(systemSymbolName: imageName, accessibilityDescription: isMuted ? "Mic Muted" : "Mic Active")
        }
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        if let button = statusItem.button {
            if popover.isShown {
                popover.performClose(sender)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                // Activate app to ensure it gets focus for shortcut recording
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }
}
