//
//  PBManager.swift
//  PBStripper
//
//  Created by Igor Ławicki on 16/07/16.
//

import Foundation
import Cocoa

class PBManager: NSObject {
    var lastChangeCount = -1
    var checkChangesCountTimer: NSTimer?

    func stop() {
        checkChangesCountTimer?.invalidate()
    }

    func start() {
        stop()
        checkChangesCountTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(checkChangeCount), userInfo: nil, repeats: true)
    }

    func checkChangeCount() {
        if lastChangeCount != NSPasteboard.generalPasteboard().changeCount {
            inspectPasteboard()
            lastChangeCount = NSPasteboard.generalPasteboard().changeCount
        }
    }

    func inspectPasteboard() {
        NSLog("INSPECTING GENERAL PASTEBOARD")
        let pb = NSPasteboard.generalPasteboard()
        let newItems = NSMutableArray.init(array: [])
        let desiredTypes = ["public.utf8-plain-text", "public.plain-text", "NSStringPboardType"]

        for pbItem in pb.pasteboardItems! {
            let newPbItem = NSPasteboardItem.init()
            for type in pbItem.types {
                if desiredTypes.contains(type) {
                    NSLog("found desired type: %@", type)
                    newPbItem.setData(pbItem.dataForType(type), forType: type)
                }
            }
            if newPbItem.types.count > 0 {
                newItems.addObject(newPbItem)
            }
        }

        if newItems.count > 0 {
            pb.clearContents()
            pb.writeObjects(newItems as NSArray as! [NSPasteboardWriting])
        }
    }
}
