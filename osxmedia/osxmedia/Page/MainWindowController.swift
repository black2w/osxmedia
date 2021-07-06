//
//  MainWindowController.swift
//  osxmedia
//
//  Created by black2w on 2021/7/6.
//

import Cocoa

class MainWindowController: BaseWindowController, NSWindowDelegate {

    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.window?.backgroundColor = NSColor.black

        let visibleFrame: NSRect! = NSScreen.main?.visibleFrame
        // 设置 window 能显示的最大 frame
        self.window?.setFrame(visibleFrame, display: true)
        // 设置 window 能显示的最小 frame
        self.window?.contentMinSize = CGSize(width: 640, height: 640*9/16.0)
        self.window?.delegate = self
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(windowDidResize(notification:)),
                                                       name: NSWindow.didResizeNotification, object: nil)
    }

            
    @objc func windowDidResize(notification: Notification) {
//        print("did resize")
//        let userInfo: NSDictionary! = notification.userInfo as NSDictionary?
//        let widthNumber: NSNumber = userInfo.object(forKey: "width") as! NSNumber
//        let heightNumber: NSNumber = userInfo.object(forKey: "height") as! NSNumber
        
        
        let window: NSWindow! = notification.object as! NSWindow
        let calWidth: CGFloat = CGFloat(Float(window.frame.size.width))
        
        //以宽为基准，强制比例16：9
//        var calWidth: CGFloat = widthNumber.floatValue as! CGFloat
        let calHeight: CGFloat = calWidth*9/16.0
        
        self.window?.setContentSize(NSSize(width: calWidth, height: calHeight))
    }
    
    
    //Mark: Window Delegate
    func windowShouldClose(sender: AnyObject) -> Bool {
        return false
    }
    
}
