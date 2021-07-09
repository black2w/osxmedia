//
//  AppDelegate.swift
//  osxmedia
//
//  Created by black2w on 2021/7/5.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var mainWindwowController: NSWindowController?


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        let  mainWC = PreViewWindowController.init(windowNibName: "PreViewWindowController")
        mainWC.showWindow(self)
        mainWC.window?.makeKeyAndOrderFront(nil)
        self.mainWindwowController = mainWC
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if flag {
            return false
        } else {
            self.mainWindwowController?.window?.makeKeyAndOrderFront(self)
            return true
        }
    }
    
}

