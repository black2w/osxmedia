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
    
    
    var deviceList: [AVCaptureDevice] = {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes:
            [.builtInMicrophone, .externalUnknown, .builtInWideAngleCamera],
            mediaType: .video, position: .unspecified)
        
        let availableCameraDevices = deviceDiscoverySession.devices
        return availableCameraDevices
    }()
    
//    var deviceTitle: [NSString] = {
//        var titlesArray: NSMutableArray
//
//        
//        return titlesArray as! [NSString]
//    }()
    
    
    
    
    @IBOutlet weak var preView: NSView!
    @IBOutlet weak var startBtn: NSButton!
    @IBOutlet weak var stopBtn: NSButton!
    
    @IBOutlet weak var videoInputBtn: NSPopUpButton!

    

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
        self.videoInputBtn.removeAllItems()
        for device in self.deviceList {
            let dev = device as AVCaptureDevice
            self.videoInputBtn.addItem(withTitle: dev.localizedName)
        }
            
        self.preView.layer?.backgroundColor = NSColor.lightGray.cgColor
        self.preView.layer?.borderWidth = 2
        self.preView.layer?.borderColor = NSColor.red.cgColor
        
        
        self.avSession = AVCaptureSession.init()
        self.avSession.sessionPreset = AVCaptureSession.Preset.hd1280x720
        
        let defaultVideoDevice: AVCaptureDevice! = self.deviceList.first
        currentViDevice = defaultVideoDevice
        self.changeCamera(videoDevice: defaultVideoDevice)
    }
    
    
    //按钮事件
    @IBAction func onStartBtnClicked(sender: Any) -> Void {
        self.startCapture()
    }
    
    @IBAction func onStopBtnClicked(sender: Any) -> Void {
        self.stopCapture()
    }
    
    @IBAction func handleInputChannelChanged (sender: NSPopUpButton) -> Void {
        let index: NSInteger = sender.indexOfSelectedItem
        let videoDevice = self.deviceList[index]
        
        self.stopCapture()
        self.changeCamera(videoDevice: videoDevice)
        self.startCapture()
    }
    
    
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
    
    private func resetDevice() -> Void {
        if self.videoOutput != nil {
            self.avSession.removeOutput(self.videoOutput)
        }
        
        if self.videoInput != nil {
            self.avSession.removeInput(self.videoInput)
        }
    }
    
    
    private func startCapture() -> Void {
        self.previewLayer = AVCaptureVideoPreviewLayer.init(session: self.avSession)
        self.previewLayer.frame = self.preView.bounds
        self.previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.preView.layer?.insertSublayer(self.previewLayer, at: 0)
        
        self.avSession.startRunning()
    }
    
    private func stopCapture() -> Void {
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
        }
    }
 

}

