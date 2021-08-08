//
//  MenuManager.swift
//  osxmedia
//
//  Created by black2w on 2021/7/8.
//

import Foundation
import Cocoa
import AVFoundation
import VideoToolbox


class MenuManager {
    static let sharedInstance = MenuManager()

    private init() {

    }
    
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
    
    
    //设置设备菜单
    func resetDeviceMenu(action: Selector) -> Void {
        self.deviceMenu.removeAllItems()
                
        for (index, device) in DeviceManager.sharedInstance.deviceList.enumerated() {
            let devobj = device as! DeviceObject
            
            let devItem: NSMenuItem!
            if devobj.captureDevice != nil {
                devItem = NSMenuItem.init(title: devobj.captureDevice!.localizedName, action: action, keyEquivalent: "")
            } else {
                let screen = devobj.screen
                devItem = NSMenuItem.init(title: screen!.displayName, action: action, keyEquivalent: "")
            }
            devobj.tag = index
            devItem.tag = index
            self.deviceMenu.addItem(devItem)
        }
    }
    
    func setSelectDevice(selectDevice: DeviceObject) -> Void {
        for (index, device) in DeviceManager.sharedInstance.deviceList.enumerated() {
            _ = device as! DeviceObject
            
            let devItem: NSMenuItem! = self.deviceMenu.item(at: index)

            if selectDevice.displayName! as String == devItem.title {
                devItem.state = NSControl.StateValue.on
            } else {
                devItem.state = NSControl.StateValue.off
            }
        }
    }
    
}
