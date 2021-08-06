//
//  PreViewWindowController.swift
//  osxmedia
//
//  Created by black2w on 2021/7/9.
//

import Cocoa
import SnapKit
import AVFoundation
import VideoToolbox


class RenderWindowController: BaseWindowController, AVRenderViewControllerDelegate {

    @IBOutlet weak var leftView: NSView!
    @IBOutlet weak var rightView: NSView!

    //左边vc
    var leftVc: AVRenderViewController! = {
        return AVRenderViewController.init()
    } ()
    
    
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.configLeftAndRight()
    }
    
    override func configWindow() {
        super.configWindow()
        // 设置 window 能显示的最大 frame
        self.window?.setFrame(NSRect(origin: CGPoint.zero, size: RENDER_TWOSCREEN_MAXSIZE), display: true)
        // 设置 window 能显示的最小 frame
        self.window?.contentMinSize = RENDER_TWOSCREEN_MINSIZE
        self.window?.setFrame(CGRect(origin: CGPoint.zero, size: RENDER_TWOSCREEN_DEFAULTSIZE), display: true)
        self.window?.center()
        self.window?.delegate = self
        self.window?.orderOut(nil)
    }
    
    override func configMyCotentVc() {
        self.leftVc.videoDataDelegate = self
        
    }
    
    override func defaultSetting() {
        super.defaultSetting()
        self.setMenu()
    }
    
    override func windowDidResize(notification: Notification) {
        self.window?.center()
    }
    
    func configLeftAndRight() -> Void {
        self.leftView.addSubview(self.leftVc.view)
        self.leftVc.view.snp_makeConstraints { (make) in
            make.edges.equalTo(self.leftView)
        }
        
        self.leftVc.view.frame = self.leftView.frame
    }
    
    
    

    
    //AVRenderViewControllerDelegate
    func didVideoDataOutPut(sampleBuffer: CMSampleBuffer) {
        
    }
}


extension RenderWindowController: NSMenuDelegate {
    private func setMenu() -> Void {
        //菜单item事件
        MenuManager.sharedInstance.deviceMenu.delegate = self
        MenuManager.sharedInstance.startMenuItem.action = #selector(startRender)
        MenuManager.sharedInstance.stopMenuItem.action = #selector(stopRender)
        MenuManager.sharedInstance.captureMenuItem.action = #selector(captureImage)
    }
    
    //nenu delegate
    func menuWillOpen(_ menu: NSMenu) {
        DeviceManager.sharedInstance.refreshDeviceList()
//        MenuManager.sharedInstance.resetDeviceMenu(action:
//                                                   #selector(deviceHasSelect))
//        MenuManager.sharedInstance.setSelectDevice(selectDevice: self.currentViDevice)
    }
}

extension RenderWindowController {
    //开始渲染
    @objc private func startRender() -> Void {

    }
    
    
    //结束渲染
    @objc private func stopRender() -> Void {

    }
    
    

    
    //截图
    @objc private func captureImage() -> Void {
//        if self.lastSampleBuffer != nil {
//            self.previewLayer.connection?.isEnabled = false
//            let data: NSData! = Tool.getDataFromCMSampleBuffer(sampleBuffer: self.lastSampleBuffer)
//            Tool.showSaveImagePanel(imageData: data, fileName: Tool.currentTime() as NSString) { (finish) in
//                self.changeInputSource(videoDevice: self.currentViDevice)
//                self.previewLayer.connection?.isEnabled = true
//            }
//        }
    }
}

