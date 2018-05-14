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
    var checkChangesCountTimer: Timer?

    func stop() {
        checkChangesCountTimer?.invalidate()
    }

    func start() {
        stop()
        checkChangesCountTimer = Timer.scheduledTimer(timeInterval: 1.2, target: self, selector: #selector(checkChangeCount), userInfo: nil, repeats: true)
    }

    @objc func checkChangeCount() {
        if lastChangeCount != NSPasteboard.general.changeCount {
            inspectPasteboard()
            lastChangeCount = NSPasteboard.general.changeCount
        }
    }

    func inspectPasteboard() {
        // INSPECTING GENERAL PASTEBOARD
        let pb = NSPasteboard.general
        let newItems = NSMutableArray.init(array: [])
        let desiredTypes = ["public.utf8-plain-text", "public.plain-text", "NSStringPboardType"]

        for pbItem in pb.pasteboardItems! {
            let newPbItem = NSPasteboardItem.init()
            for type in pbItem.types {
                if desiredTypes.contains(type.rawValue) {
                    // found desired type
                    newPbItem.setData(pbItem.data(forType: type)!, forType: type)
                }
            }
            if newPbItem.types.count > 0 {
                newItems.add(newPbItem)
            }
        }

        if newItems.count > 0 {
            pb.clearContents()
            pb.writeObjects(newItems as NSArray as! [NSPasteboardWriting])
        }
    }
}
