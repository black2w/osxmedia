//
//  DeviceManager.swift
//  osxmedia
//
//  Created by black2w on 2021/7/8.
//

import Foundation
import AVFoundation
import VideoToolbox
import Cocoa

class DeviceManager {
    static let sharedInstance = DeviceManager()
    
    //设备列表
    var deviceList: NSMutableArray! = {
        return NSMutableArray.init()
    } ()
    
    private init() {
        self.refreshDeviceList()
    }

    
    
    //刷新设备列表
    func refreshDeviceList() -> Void {
        self.deviceList.removeAllObjects()
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes:
            [.builtInMicrophone, .externalUnknown, .builtInWideAngleCamera],
            mediaType: .video, position: .unspecified)
        let availableCameraDevices = deviceDiscoverySession.devices
        
        
        //添加摄像头
        for device in availableCameraDevices {
            let deviceObj: DeviceObject! = DeviceObject.init()
            deviceObj.captureDevice = device
            deviceObj.screen = nil
            deviceObj.displayName = device.localizedName as NSString
            self.deviceList.add(deviceObj!)
        }
        
        
        //遍历屏幕
        for screen in SCRREENS {
            //添加屏幕
            let sct = screen as! NSScreen
            let screenObj: DeviceObject! = DeviceObject.init()
            screenObj.captureDevice = nil
            screenObj.screen = screen as? NSScreen
            screenObj.displayName = sct.displayName as NSString
            self.deviceList.add(screenObj!)
        }
    }

    
    
}
