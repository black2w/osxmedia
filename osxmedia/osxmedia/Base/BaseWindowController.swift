//
//  BaseWindowController.swift
//  osxmedia
//
//  Created by black2w on 2021/7/6.
//

import Cocoa

class BaseWindowController: NSWindowController, NSWindowDelegate {

    override func windowDidLoad() {
        super.windowDidLoad()
        self.configWindow()
        self.configMyCotentVc()
        
        NotificationCenter.default.addObserver(self, selector: #selector(windowDidResize(notification:)),
                                                       name: NSWindow.didResizeNotification, object: nil)
    }
    
    override func windowWillLoad() {
        super.windowWillLoad()
    }
    
    override func loadWindow() {
        super.loadWindow()
    }
    
    func configWindow() -> Void {
        self.window?.backgroundColor = NSColor.black
    }
    
    func configMyCotentVc() -> Void {
        
    }
    
    func defaultSetting() -> Void{
        
    }
    
    @objc func windowDidResize(notification: Notification) {
        self.window?.center()
    }

    
    //Mark: Window Delegate
    func windowShouldClose(sender: AnyObject) -> Bool {
        return false
    }
    
}
