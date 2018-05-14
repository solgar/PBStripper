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
    var hideNotificationTimer: Timer? = nil
    var strippingEnabled = true
    var pbManager: PBManager = PBManager.init()


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        menubarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        let img = NSImage(named: NSImage.Name(rawValue: "stripper"))
        menubarItem.image = img
        menubarItem.action = #selector(menuIconClicked)
        pbManager.start()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @objc func menuIconClicked(sender: NSObject) {
        lockQueue.sync() {
            if self.notification != nil {
                self.hideNotificationTimer?.invalidate()
                NSUserNotificationCenter.default.removeDeliveredNotification(self.notification!)
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
            if self.notification != nil {
                NSUserNotificationCenter.default.removeDeliveredNotification(self.notification!)
                self.notification = nil
            }
        }
    }


}

