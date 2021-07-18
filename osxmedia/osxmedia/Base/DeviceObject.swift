//
//  DeviceObject.swift
//  osxmedia
//
//  Created by black2w on 2021/7/18.
//

import Cocoa
import AVFoundation
import VideoToolbox

class DeviceObject: NSObject {
    
    override init() {
        super.init()
        
        self.captureDevice = nil
        self.screen = nil
        self.tag = -1
        self.displayName = nil
    }
    
    var captureDevice: AVCaptureDevice?
    var screen: NSScreen?
    var tag: Int?
    var displayName: NSString?
    

}
