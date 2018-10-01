//
//  AppDelegate.swift
//  PBStripper
//
//  Created by Igor Ławicki on 15/07/16.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet var menubarItem: NSStatusItem!
    var darkMode: Bool = false
    var notification: NSUserNotification? = nil
    let lockQueue = DispatchQueue(label: "com.lawicki.igor.PBStripper.notificationQueue")
    var hideNotificationTimer: Timer = Timer()
    var strippingEnabled = true
    var pbManager: PBManager = PBManager.init()


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        menubarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        let img = NSImage(named: "stripper")
        menubarItem.image = img
        menubarItem.action = #selector(menuIconClicked)
        guard let button = menubarItem.button else {
            fatalError("Failed to create menu bar item button.")
        }
        button.image = NSImage(named: "stripper")
        button.image!.isTemplate = true
        button.target = self
        button.action = #selector(menuIconClicked)
        pbManager.start()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @objc func menuIconClicked(sender: NSObject) {
        lockQueue.sync() {
            if let pending = self.notification {
                self.hideNotificationTimer.invalidate()
                NSUserNotificationCenter.default.removeDeliveredNotification(pending)
            }
            self.strippingEnabled = !self.strippingEnabled
            if self.strippingEnabled == true {
                self.pbManager.start()
            } else {
                self.pbManager.stop()
            }
            self.notification = NSUserNotification.init()
            self.notification!.title = "PBStripper"
            self.notification!.informativeText = "Stripping enabled: \(self.strippingEnabled)"
            NSUserNotificationCenter.default.deliver(self.notification!)

            self.hideNotificationTimer = Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(self.hideYoMamma), userInfo: nil, repeats: false)
        }
    }

    @objc func hideYoMamma() {
        lockQueue.sync() {
            if let notification = self.notification {
                NSUserNotificationCenter.default.removeDeliveredNotification(notification)
                self.notification = nil
            }
        }
    }


}

