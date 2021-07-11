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
    
    var currentViDevice: AVCaptureDevice!
    var videoInput: AVCaptureDeviceInput!
    
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
            self.resizePreviewerByWindow()
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
    
    private func defaultSetting() -> Void {
        //菜单item事件
        MenuManager.sharedInstance.deviceMenu.delegate = self
        MenuManager.sharedInstance.startMenuItem.action = #selector(startCapture)
        MenuManager.sharedInstance.stopMenuItem.action = #selector(stopCapture)
        MenuManager.sharedInstance.captureMenuItem.action = #selector(captureImage)
        
        //preview set
        self.preView.layer?.backgroundColor = NSColor.lightGray.cgColor
        self.preView.layer?.borderWidth = 2
        self.preView.layer?.borderColor = NSColor.red.cgColor
        
        if self.avSession == nil {
            self.avSession = AVCaptureSession.init()
            self.avSession.sessionPreset = AVCaptureSession.Preset.hd1280x720
        }
        
        if self.previewLayer == nil {
            self.previewLayer = AVCaptureVideoPreviewLayer.init(session: self.avSession)
            self.previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        }
        if self.previewLayer.superlayer == nil {
            self.preView.layer = self.previewLayer
        }

    
        //默认设备
        let defaultVideoDevice: AVCaptureDevice! = DeviceManager.sharedInstance.deviceList.first
        currentViDevice = defaultVideoDevice
        self.changeCamera(videoDevice: defaultVideoDevice)
    }
            
    //随动preview
    public func resizePreviewer() -> Void {
        if (self.preView != nil) && (self.previewLayer != nil) {

        }
    }
    
    //根据window的大小进行resize
    public func resizePreviewerByWindow() -> Void {
        if (self.preView != nil) && (self.previewLayer != nil) {
            if self.view.window == nil {
                return
            } else {
//                self.previewLayer.frame = Tool.generatrRenderFrameByWindow(window: self.view.window!)
                self.view.frame = Tool.generatrRenderFrameByWindow(window: self.view.window!)
            }
        }
    }
    
    //切换摄像头
    private func changeCamera(videoDevice: AVCaptureDevice) -> Void {
        self.resetDeviceCapture()
        
        self.currentViDevice = videoDevice
        MenuManager.sharedInstance.resetDeviceMenu(selectDevice: self.currentViDevice, action: #selector(deviceHasSelect))

        
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
    private func resetDeviceCapture() -> Void {
        if self.videoOutput != nil {
            self.avSession.removeOutput(self.videoOutput)
        }
        
        if self.videoInput != nil {
            self.avSession.removeInput(self.videoInput)
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
                self.changeCamera(videoDevice: self.currentViDevice)
                self.previewLayer.connection?.isEnabled = true
            }
        }
    }
    
    
    //切换设备
    @objc private func deviceHasSelect(item: NSMenuItem) -> Void {
        let index: Int = item.tag
        let videoDevice = DeviceManager.sharedInstance.deviceList[index]
        
        self.stopCapture()
        self.changeCamera(videoDevice: videoDevice)
        self.startCapture()
        
    }
    
    
    //nenu delegate
    func menuWillOpen(_ menu: NSMenu) {
        DeviceManager.sharedInstance.refreshDeviceList()
        MenuManager.sharedInstance.resetDeviceMenu(selectDevice: self.currentViDevice, action:
                                                   #selector(deviceHasSelect))
    }

    //capture delegate
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if output == self.videoOutput {
            self.lastSampleBuffer = sampleBuffer
        }
    }
 

}


