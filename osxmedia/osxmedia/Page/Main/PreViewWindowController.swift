//
//  PreViewWindowController.swift
//  osxmedia
//
//  Created by black2w on 2021/7/9.
//

import Cocoa

class PreViewWindowController: BaseWindowController , NSWindowDelegate {
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.window?.backgroundColor = NSColor.black

        // 设置 window 能显示的最大 frame
        self.window?.setFrame(NSRect(origin: CGPoint.zero, size: PREVIEW_MAXSIZE), display: true)
        // 设置 window 能显示的最小 frame
        self.window?.contentMinSize = PREVIEW_MINSIZE
        self.window?.setFrame(CGRect(origin: CGPoint.zero, size: PREVIEW_DEFAULTSIZE), display: true)
        self.window?.center()
        self.window?.delegate = self
        self.window?.orderOut(nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(windowDidResize(notification:)),
                                                       name: NSWindow.didResizeNotification, object: nil)
    
        self.window?.contentViewController = PreViewController.init(nibName: "PreViewController", bundle: nil)
    }
    
    
    @objc private func windowDidResize(notification: Notification) {
        let calWidth: CGFloat! = (self.window?.frame.size.width ?? 0) < PREVIEW_MINHEIGHT ? PREVIEW_MINHEIGHT : self.window?.frame.size.width
        //以宽为基准，强制比例16：9
        let calHeight: CGFloat = calWidth * PREVIEWSCALE
        
        self.window?.setContentSize(NSSize(width: calWidth, height: calHeight))
        let vc: PreViewController! = self.contentViewController as? PreViewController
        vc.resizePreviewer()
        self.window?.center()
    }
    
    
    //Mark: Window Delegate
    func windowShouldClose(sender: AnyObject) -> Bool {
        return false
    }
    
}

