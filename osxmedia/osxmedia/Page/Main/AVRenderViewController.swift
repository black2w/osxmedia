//
//  AVRenderViewController.swift
//  osxmedia
//
//  Created by black2w on 2021/8/6.
//

import Cocoa
import AVFoundation
import VideoToolbox


//AVRenderVC协议
protocol AVRenderViewControllerDelegate {
    func didVideoDataOutPut(sampleBuffer: CMSampleBuffer) -> Void
}

class AVRenderViewController: BaseViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    //输入设备
    public var deviceObject: DeviceObject! {
        didSet {
            
        }
    }
    
    //视频数据处理的委托对象
    public var videoDataDelegate: AVRenderViewControllerDelegate!
    
    
    private var avSession: AVCaptureSession! = {
        return AVCaptureSession.init()
    } ()
    
    private var videoOutput: AVCaptureVideoDataOutput! = {
        return AVCaptureVideoDataOutput.init()
    } ()
    
    //显示的layer
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var videoInput: Any!  //输入设备


    

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
    }
        
    override func viewWillDisappear() {
        super.viewWillDisappear()
//        self.stopCapture()
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            self.startCapture() //默认开始
        }
    }
    
    override func defaultSetting() -> Void {
         self.videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global())
               
        if self.previewLayer == nil {
            self.previewLayer = AVCaptureVideoPreviewLayer.init(session: self.avSession)
            self.previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        }
        
        if self.previewLayer.superlayer == nil {
            self.view.layer = self.previewLayer
        }
    }
    
    
    //设置输入源
    private func setInputSource(videoDevice: DeviceObject) -> Void {
        self.resetDeviceCapture()
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
    
    //开始显示
    public func startCapture() -> Void {
        self.avSession.startRunning()
    }
    
    //停止显示
    public func stopCapture() -> Void {
        if self.avSession.isRunning {
            self.avSession.stopRunning()
        }
    }


    //capture delegate
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if output == self.videoOutput {
            if self.videoDataDelegate != nil {
                self.videoDataDelegate.didVideoDataOutPut(sampleBuffer: sampleBuffer)
            }

        }
    }
    
}
