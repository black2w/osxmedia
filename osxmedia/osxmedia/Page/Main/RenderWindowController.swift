//
//  PreViewWindowController.swift
//  osxmedia
//
//  Created by black2w on 2021/7/9.
//

import Cocoa

class RenderWindowController: BaseWindowController , NSWindowDelegate {
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.window?.backgroundColor = NSColor.black

        // 设置 window 能显示的最大 frame
        self.window?.setFrame(NSRect(origin: CGPoint.zero, size: RENDER_MAXSIZE), display: true)
        // 设置 window 能显示的最小 frame
        self.window?.contentMinSize = RENDER_MINSIZE
        self.window?.setFrame(CGRect(origin: CGPoint.zero, size: RENDER_DEFAULTSIZE), display: true)
        self.window?.center()
        self.window?.delegate = self
        self.window?.orderOut(nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(windowDidResize(notification:)),
                                                       name: NSWindow.didResizeNotification, object: nil)
    
        self.window?.contentViewController = RenderViewController.init(nibName: "RenderViewController", bundle: nil)
    }
    
    
    @objc private func windowDidResize(notification: Notification) {
//        let calWidth: CGFloat! = (self.window?.frame.size.width ?? 0) < RENDER_MINHEIGHT ? RENDER_MINHEIGHT : self.window?.frame.size.width
//        //以宽为基准，强制比例16：9
//        let calHeight: CGFloat = calWidth * RENDERRATIO
//        
//        self.window?.setContentSize(NSSize(width: calWidth, height: calHeight))
        let vc: RenderViewController! = self.contentViewController as? RenderViewController
        vc.resizePreviewerByWindow()
        self.window?.center()
    }
    
    
    //Mark: Window Delegate
    func windowShouldClose(sender: AnyObject) -> Bool {
        return false
    }
    
}

