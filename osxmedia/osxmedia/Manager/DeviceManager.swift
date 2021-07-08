//
//  DeviceManager.swift
//  osxmedia
//
//  Created by black2w on 2021/7/8.
//

import Foundation
import AVFoundation
import VideoToolbox


class DeviceManager {
    static let sharedInstance = DeviceManager()
    
    //设备列表
    var deviceList: [AVCaptureDevice]!
    
    private init() {
        self.refreshDeviceList()
    }

    
    
    //刷新设备列表
    func refreshDeviceList() -> Void {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes:
            [.builtInMicrophone, .externalUnknown, .builtInWideAngleCamera],
            mediaType: .video, position: .unspecified)
        let availableCameraDevices = deviceDiscoverySession.devices
        
        self.deviceList = availableCameraDevices
    }

    
    
}
