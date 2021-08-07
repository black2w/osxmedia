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


class RenderWindowController: BaseWindowController, AVCapturePreViewControllerDelegate {

    @IBOutlet weak var leftView: NSView!
    @IBOutlet weak var rightView: NSView!

    //左边vc
    var avCaptureVc: AVCapturePreViewController! = {
        return AVCapturePreViewController.init(nibName: "AVCapturePreViewController", bundle: nil)
    } ()
    
    //当前选择的设备
    var currentViDevice: DeviceObject!
    var lastSampleBuffer: CMSampleBuffer!  //最后一帧图像

    
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
        
    }
    
    override func defaultSetting() {
        super.defaultSetting()
        
        self.leftView.wantsLayer = true;///设置背景颜色
        self.leftView.layer!.backgroundColor = NSColor.red.cgColor
        
        self.rightView.wantsLayer = true;///设置背景颜色
        self.rightView.layer!.backgroundColor = NSColor.blue.cgColor
        
        
        self.configDevice()
        self.setMenu()
    }
    
    override func windowDidResize(notification: Notification) {
        self.window?.center()
    }
    
    func configLeftAndRight() -> Void {
        self.avCaptureVc.videoDataDelegate = self
        self.leftView.addSubview(self.avCaptureVc.view)
        self.avCaptureVc.view.snp_makeConstraints { (make) in
            make.edges.equalTo(self.leftView)
        }
    }
    
    func configDevice() -> Void {
        //默认设备
        let defaultVideoDevice: DeviceObject! = DeviceManager.sharedInstance.deviceList.object(at: 0) as? DeviceObject
        self.currentViDevice = defaultVideoDevice
        self.changeInputSource(videoDevice: defaultVideoDevice)

    }
    
    
    

    
    //AVRenderViewControllerDelegate
    func didVideoDataOutPut(sampleBuffer: CMSampleBuffer) {
        self.lastSampleBuffer = sampleBuffer
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
        //这边的目的，是每次打开时刷新下设备列表。解决应用运行期间，有设备插拔。需要用设备通知的方式处理
        DeviceManager.sharedInstance.refreshDeviceList()
        MenuManager.sharedInstance.resetDeviceMenu(action:
                                                   #selector(deviceHasSelect))
        MenuManager.sharedInstance.setSelectDevice(selectDevice: self.currentViDevice)
    }
}

extension RenderWindowController {
    //切换设备
    @objc private func deviceHasSelect(item: NSMenuItem) -> Void {
        let index: Int = item.tag
        let videoDevice = DeviceManager.sharedInstance.deviceList[index]
        MenuManager.sharedInstance.setSelectDevice(selectDevice: self.currentViDevice)

        
        self.stopRender()
        self.changeInputSource(videoDevice: videoDevice as! DeviceObject)
        self.startRender()
    }
    
    //切换摄像头
    private func changeInputSource(videoDevice: DeviceObject) -> Void {
        self.currentViDevice  = videoDevice
        self.avCaptureVc.deviceObject = videoDevice
        
    }
}

extension RenderWindowController {
    //开始渲染
    @objc private func startRender() -> Void {
        self.avCaptureVc.startCapture()
    }
    
    
    //结束渲染
    @objc private func stopRender() -> Void {
        self.avCaptureVc.stopCapture()
    }
    
    

    
    //截图
    @objc private func captureImage() -> Void {
        if self.lastSampleBuffer != nil {
            self.avCaptureVc.pausePreview()
            let data: NSData! = Tool.getDataFromCMSampleBuffer(sampleBuffer: self.lastSampleBuffer)
            Tool.showSaveImagePanel(imageData: data, fileName: Tool.currentTime() as NSString) { (finish) in
                self.changeInputSource(videoDevice: self.currentViDevice)
                self.avCaptureVc.resumePreview()
            }
        }
    }
}

