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

    let enabledImage = NSImage(named: "stripper")!
    let disabledImage = NSImage(named: "stripper_disabled")!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        menubarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        guard let button = menubarItem.button else {
            fatalError("Cannot get menu bar button.")
        }

        setStatusBarImage(image: enabledImage)

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
                setStatusBarImage(image: enabledImage)
                self.pbManager.start()
            } else {
                setStatusBarImage(image: disabledImage)
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

    func setStatusBarImage(image: NSImage) {
        guard let button = menubarItem.button else {
            fatalError("Cannot get menu bar button.")
        }

        button.image = image
        button.image?.isTemplate = true
    }
}
