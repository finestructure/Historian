//
//  AppDelegate.swift
//  Historian
//
//  Created by Sven A. Schmidt on 16/03/2020.
//  Copyright © 2020 finestructure. All rights reserved.
//

import Cocoa
import HistoryView
import SwiftUI


var historyStore = HistoryView.store(history: [], broadcastEnabled: true)


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        Transceiver.shared.receive(Message.self) { msg in
            historyStore.send(HistoryView.Action.appendStep("\(msg.action)", msg.state))
        }
        Transceiver.shared.resume()

        let contentView = HistoryView(store: historyStore)
            .environmentObject(Transceiver.dataSource)

        // Create the window and set the content view. 
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

