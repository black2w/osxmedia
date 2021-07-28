//
//  PreViewWindowController.swift
//  osxmedia
//
//  Created by black2w on 2021/7/9.
//

import Cocoa

class RenderWindowController: BaseWindowController , NSWindowDelegate {
    
    @IBOutlet weak var leftView: NSView!
    @IBOutlet weak var rightView: NSView!
    
    var leftVc: RenderViewController! = {
        return RenderViewController.init(nibName: "RenderViewController", bundle: nil)
    } ()
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.configLeftAndRight()
    }
    
    override func configWindow() {
        super.configWindow()
        // 设置 window 能显示的最大 frame
        self.window?.setFrame(NSRect(origin: CGPoint.zero, size: RENDER_MAXSIZE), display: true)
        // 设置 window 能显示的最小 frame
        self.window?.contentMinSize = RENDER_MINSIZE
        self.window?.setFrame(CGRect(origin: CGPoint.zero, size: RENDER_DEFAULTSIZE), display: true)
        self.window?.center()
        self.window?.delegate = self
        self.window?.orderOut(nil)
    }
    
    override func configMyCotentVc() {
//        self.window?.contentViewController = RenderViewController.init(nibName: "RenderViewController", bundle: nil)
    }
    
    func configLeftAndRight() -> Void {
        self.leftView.addSubview(self.leftVc.view)
    }
    
    @objc override func windowDidResize(notification: Notification) {
//        let vc: RenderViewController! = self.contentViewController as? RenderViewController
//        vc.resizePreviewerByWindow()
        self.window?.center()
    }
    
    
    //Mark: Window Delegate
    func windowShouldClose(sender: AnyObject) -> Bool {
        return false
    }
    
}

