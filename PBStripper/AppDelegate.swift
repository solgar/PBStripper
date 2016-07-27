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
    let lockQueue = dispatch_queue_create("com.lawicki.igor.PBStripper.notificationQueue", nil)
    var hideNotificationTimer: NSTimer? = nil
    var strippingEnabled = true
    var pbManager: PBManager = PBManager.init()


    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        menubarItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
        let img = NSImage.init(imageLiteral: "stripper")
        menubarItem.image = img
        menubarItem.action = #selector(menuIconClicked)
        pbManager.start()
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    func menuIconClicked(sender: NSObject) {
        dispatch_sync(lockQueue) {
            if self.notification != nil {
                self.hideNotificationTimer?.invalidate()
                NSUserNotificationCenter.defaultUserNotificationCenter().removeDeliveredNotification(self.notification!)
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
            NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(self.notification!)

            self.hideNotificationTimer = NSTimer.scheduledTimerWithTimeInterval(2.5, target: self, selector: #selector(self.hideYoMamma), userInfo: nil, repeats: false)
        }
    }

    func hideYoMamma() {
        dispatch_sync(lockQueue) {
            if self.notification != nil {
                NSUserNotificationCenter.defaultUserNotificationCenter().removeDeliveredNotification(self.notification!)
                self.notification = nil
            }
        }
    }


}

