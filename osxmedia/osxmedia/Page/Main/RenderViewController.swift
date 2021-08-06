//
//  PreViewController.swift
//  osxmedia
//
//  Created by black2w on 2021/7/9.
//

import Cocoa
import AVFoundation
import VideoToolbox

class RenderViewController: BaseViewController, AVCaptureAudioDataOutputSampleBufferDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, NSMenuDelegate {
    
    var avSession: AVCaptureSession!
    var videoOutput: AVCaptureVideoDataOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var currentViDevice: DeviceObject!
    var videoInput: Any!  //输入设备
    
    var lastSampleBuffer: CMSampleBuffer!  //最后一帧图像
    
    
    @IBOutlet weak var preView: NSView!


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.defaultSetting()
    }
    
    
    override func viewDidAppear() {
        super.viewDidAppear()
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        self.stopCapture()

    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.startCapture() //默认开始
        }
    }
        
    
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    override func defaultSetting() -> Void {
        self.setMenu()
        self.setAv()
    }
    
    private func setAv() -> Void {
        //preview set
        self.preView.layer?.backgroundColor = NSColor.lightGray.cgColor
        self.preView.layer?.borderWidth = 2
        self.preView.layer?.borderColor = NSColor.red.cgColor
        
        if self.avSession == nil {
            self.avSession = AVCaptureSession.init()
        }
        
        if self.previewLayer == nil {
            self.previewLayer = AVCaptureVideoPreviewLayer.init(session: self.avSession)
            self.previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        }
        if self.previewLayer.superlayer == nil {
            self.preView.layer = self.previewLayer
        }

    
        //默认设备
        let defaultVideoDevice: DeviceObject! = DeviceManager.sharedInstance.deviceList.object(at: 0) as? DeviceObject
        currentViDevice = defaultVideoDevice
        self.changeInputSource(videoDevice: defaultVideoDevice)
    }
    
    private func setMenu() -> Void {
        //菜单item事件
        MenuManager.sharedInstance.deviceMenu.delegate = self
        MenuManager.sharedInstance.startMenuItem.action = #selector(startCapture)
        MenuManager.sharedInstance.stopMenuItem.action = #selector(stopCapture)
        MenuManager.sharedInstance.captureMenuItem.action = #selector(captureImage)
    }
            

    //切换摄像头
    private func changeInputSource(videoDevice: DeviceObject) -> Void {
        self.resetDeviceCapture()
        
        self.currentViDevice = videoDevice
        MenuManager.sharedInstance.resetDeviceMenu(action: #selector(deviceHasSelect))
        MenuManager.sharedInstance.setSelectDevice(selectDevice: self.currentViDevice)
        
        if videoDevice.captureDevice != nil {
            self.videoInput = try! AVCaptureDeviceInput(device: videoDevice.captureDevice!)
        } else {
            let screen = videoDevice.screen! as NSScreen
            let screenId = screen.number
            
            self.videoInput = AVCaptureScreenInput.init(displayID: screenId)
            let vIn = videoInput as! AVCaptureScreenInput
            vIn.cropRect = screen.frame
            vIn.minFrameDuration = CMTimeMake(value: 1, timescale: 30)
        }

        
        
        self.videoOutput = AVCaptureVideoDataOutput.init()
        self.videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global())

                
        if self.avSession.canAddInput(self.videoInput! as! AVCaptureInput) {
            self.avSession.addInput(self.videoInput as! AVCaptureInput)
        }

        if self.avSession.canAddOutput(self.videoOutput) {
            self.avSession.addOutput(self.videoOutput)
        }
    }
    
    //重置
    private func resetDeviceCapture() -> Void {
        if self.videoOutput != nil {
            self.avSession.removeOutput(self.videoOutput)
        }
        
        if self.videoInput != nil {
            self.avSession.removeInput(self.videoInput as! AVCaptureInput)
        }
    }
    
    //结束采集
    @objc private func stopCapture() -> Void {
        if self.avSession.isRunning {
            self.avSession.stopRunning()
        }
    }
    
    
    //开始采集
    @objc private func startCapture() -> Void {
        self.avSession.startRunning()
    }
    
    //截图
    @objc private func captureImage() -> Void {
        if self.lastSampleBuffer != nil {
            self.previewLayer.connection?.isEnabled = false
            let data: NSData! = Tool.getDataFromCMSampleBuffer(sampleBuffer: self.lastSampleBuffer)
            Tool.showSaveImagePanel(imageData: data, fileName: Tool.currentTime() as NSString) { (finish) in
                self.changeInputSource(videoDevice: self.currentViDevice)
                self.previewLayer.connection?.isEnabled = true
            }
        }
    }
    
    
    //切换设备
    @objc private func deviceHasSelect(item: NSMenuItem) -> Void {
        let index: Int = item.tag
        let videoDevice = DeviceManager.sharedInstance.deviceList[index]
        
        self.stopCapture()
        self.changeInputSource(videoDevice: videoDevice as! DeviceObject)
        self.startCapture()
        
    }
    
    
    //nenu delegate
    func menuWillOpen(_ menu: NSMenu) {
        DeviceManager.sharedInstance.refreshDeviceList()
        MenuManager.sharedInstance.resetDeviceMenu(action:
                                                   #selector(deviceHasSelect))
        MenuManager.sharedInstance.setSelectDevice(selectDevice: self.currentViDevice)
    }
    

    //capture delegate
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if output == self.videoOutput {
            self.lastSampleBuffer = sampleBuffer
        }
    }
 

}


