//
//  ViewController.swift
//  osxmedia
//
//  Created by black2w on 2021/7/5.
//

import Cocoa
import AVFoundation
import VideoToolbox

class ViewController: NSViewController, AVCaptureAudioDataOutputSampleBufferDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var avSession: AVCaptureSession!
    var videoOutput: AVCaptureVideoDataOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var currentViDevice: AVCaptureDevice!
    var videoInput: AVCaptureDeviceInput!
    
    var lastSampleBuffer: CMSampleBuffer!
    
    //系统菜单
    var mainMenu: NSMenu! = {
        return NSApp.mainMenu
    }()
    
    //菜单子项，item 控制
    var ctrlMenuItem: NSMenuItem! = {
        return NSApp.mainMenu?.item(at: 1)
    }()
    
    //控制Menu
    lazy var ctrlMenu: NSMenu! = {
        return self.ctrlMenuItem.submenu
    }()
    
    //开始
    lazy var startMenuItem: NSMenuItem! = {
        return self.ctrlMenu?.item(at: 0)
    }()
    
    //停止
    lazy var stopMenuItem: NSMenuItem! = {
        return self.ctrlMenu?.item(at: 1)
    }()
    
    //设备
    lazy var deviceMenuItem: NSMenuItem! = {
        return self.ctrlMenu?.item(at: 2)
    }()
    
    //设备menu
    lazy var deviceMenu: NSMenu! = {
        return self.deviceMenuItem.submenu
    }()
    
    //截图item
    lazy var captureMenuItem: NSMenuItem! = {
        return self.ctrlMenu?.item(at: 3)
    }()
    
    //设备列表
    var deviceList: [AVCaptureDevice] = {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes:
            [.builtInMicrophone, .externalUnknown, .builtInWideAngleCamera],
            mediaType: .video, position: .unspecified)
        
        let availableCameraDevices = deviceDiscoverySession.devices
        return availableCameraDevices
    }()
    


    
    @IBOutlet weak var preView: NSView!


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.defaultSetting()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    private func defaultSetting() -> Void {
        self.resetDeviceMenu()
        
        //菜单item事件
        self.startMenuItem.action = #selector(startCapture)
        self.stopMenuItem.action = #selector(stopCapture)
        self.captureMenuItem.action = #selector(captureImage)
        
        self.preView.layer?.backgroundColor = NSColor.lightGray.cgColor
        self.preView.layer?.borderWidth = 2
        self.preView.layer?.borderColor = NSColor.red.cgColor
        
        
        self.avSession = AVCaptureSession.init()
        self.avSession.sessionPreset = AVCaptureSession.Preset.hd1280x720
        
        let defaultVideoDevice: AVCaptureDevice! = self.deviceList.first
        currentViDevice = defaultVideoDevice
        self.changeCamera(videoDevice: defaultVideoDevice)
    }
    
    //设置设备菜单
    private func resetDeviceMenu() -> Void {
        self.deviceMenu.removeAllItems()
        for (index, device) in self.deviceList.enumerated() {
            let dev = device as AVCaptureDevice
            var devItem: NSMenuItem! = NSMenuItem.init(title: dev.localizedName, action: #selector(deviceHasSelect), keyEquivalent: "")
            devItem.tag = index
            self.deviceMenu.addItem(devItem)
        }
    }
    
    
    //切换设备
    @objc private func deviceHasSelect(item: NSMenuItem) -> Void {
        let index: Int = item.tag
        let videoDevice = self.deviceList[index]
        
        self.stopCapture()
        self.changeCamera(videoDevice: videoDevice)
        self.startCapture()
        
    }
    
    //随动preview
    public func resizePreviewer() -> Void {
        if (self.preView != nil) && (self.previewLayer != nil) {
            self.previewLayer.frame = self.preView.bounds
        }
    }
    
    //切换摄像头
    private func changeCamera(videoDevice: AVCaptureDevice) -> Void {
        self.resetDevice()
        
        self.currentViDevice = videoDevice
        self.videoInput = try! AVCaptureDeviceInput(device: videoDevice)
        
        self.videoOutput = AVCaptureVideoDataOutput.init()
        self.videoOutput.videoSettings = [String.init(kCVPixelBufferPixelFormatTypeKey): NSNumber.init(value: kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange),
                                                  String.init(kCVPixelBufferWidthKey): NSNumber.init(value: 1280),
                                                  String.init(kCVPixelBufferHeightKey): NSNumber.init(value: 720)]
        self.videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global())

                
        if self.avSession.canAddInput(videoInput) {
            self.avSession.addInput(videoInput)
        }

        if self.avSession.canAddOutput(self.videoOutput) {
            self.avSession.addOutput(self.videoOutput)
        }
    }
    
    
    //重置
    private func resetDevice() -> Void {
        if self.videoOutput != nil {
            self.avSession.removeOutput(self.videoOutput)
        }
        
        if self.videoInput != nil {
            self.avSession.removeInput(self.videoInput)
        }
    }
    
    //开始采集
    @objc private func startCapture() -> Void {
        if self.previewLayer == nil {
            self.previewLayer = AVCaptureVideoPreviewLayer.init(session: self.avSession)
            self.previewLayer.frame = self.preView.bounds
            self.previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        }
        if self.previewLayer.superlayer == nil {
            self.preView.layer?.insertSublayer(self.previewLayer, at: 0)
        }
        
        self.avSession.startRunning()
    }
    
    //截图
    @objc private func captureImage() -> Void {
        if self.lastSampleBuffer != nil {
            self.previewLayer.connection?.isEnabled = false
            let data: NSData! = Tool.getDataFromCMSampleBuffer(sampleBuffer: self.lastSampleBuffer)
            Tool.showSaveImagePanel(imageData: data, fileName: Tool.currentTime() as NSString) { (finish) in
                self.changeCamera(videoDevice: self.currentViDevice)
                self.previewLayer.connection?.isEnabled = true
            }
        }
    }
    
    //结束采集
    @objc private func stopCapture() -> Void {
        if self.avSession.isRunning {
            self.avSession.stopRunning()
        }
        
        if self.previewLayer != nil {
            self.previewLayer.removeFromSuperlayer()
        }
    }
    
    
    //capture delegate
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if output == self.videoOutput {
            print("获得图像数据")
            self.lastSampleBuffer = sampleBuffer
        }
    }
 

}

