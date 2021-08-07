//
//  SampleBufferDisplayViewController.swift
//  osxmedia
//
//  Created by black2w on 2021/8/7.
//

import Cocoa
import AVFoundation
import VideoToolbox


class SampleBufferDisplayViewController: BaseViewController {
    
    var displayLayer: AVSampleBufferDisplayLayer! = {
        return AVSampleBufferDisplayLayer.init()
    } ()
    
    var sampleBuffer: CMSampleBuffer! {
        didSet {
            self.renderSampleBuffer(buffer: sampleBuffer)
        }
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func defaultSetting() {
        self.displayLayer.videoGravity = .resizeAspect
        self.view.layer = self.displayLayer
    }
    
    func renderSampleBuffer(buffer: CMSampleBuffer) -> Void {
        if self.displayLayer.isReadyForMoreMediaData {
            self.displayLayer.enqueue(buffer)
        }
    }
    
}
