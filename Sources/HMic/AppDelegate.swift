import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarController: StatusBarController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the status bar controller
        statusBarController = StatusBarController()
        
        // Hide the dock icon since this is a menu bar app
        // Note: In a real app, this should be set in Info.plist (LSUIElement = YES)
        // But we can also try to set it programmatically for development convenience
        NSApp.setActivationPolicy(.accessory)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
