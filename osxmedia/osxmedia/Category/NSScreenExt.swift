//
//  NSScreenExt.swift
//  osxmedia
//
//  Created by black2w on 2021/7/18.
//

import Foundation
import Cocoa

extension NSScreen {
    //屏幕id
    var number: CGDirectDisplayID {
        let screen_info = self.deviceDescription
        let screen_id = screen_info[NSDeviceDescriptionKey("NSScreenNumber")] as! NSNumber
        return CGDirectDisplayID((screen_id).intValue)
    }

    //名字
    var displayName: String {
        guard let info = infoForCGDisplay((self as NSScreen).number, options: kIODisplayOnlyPreferredName) else {
            return "Unknown screen"
        }
        
        guard let localizedNames = info[kDisplayProductName] as! NSDictionary? as Dictionary?,
            let name           = localizedNames.values.first as! NSString? as String? else {
                return "Unnamed screen"
            }
            return name
        }
    
    //返回点在的屏幕
//    static func getScreen(_ point: NSPoint) -> NSScreen {
//        var screenRes: NSScreen?
//        if let screens = NSScreen.screens as [NSScreen]? {
//            for screen in screens {
//                if NSMouseInRect(point, screen.frame, false) {
//                    screenRes = screen
//                }
//            }
//        }
//
//        return screenRes!
//    }
}

private func infoForCGDisplay(_ displayID: CGDirectDisplayID, options: Int) -> [AnyHashable: Any]? {
    var iter: io_iterator_t = 0
    
    let services = IOServiceMatching("IODisplayConnect")
    let err = IOServiceGetMatchingServices(kIOMasterPortDefault, services, &iter)
    guard err == KERN_SUCCESS else {
        NSLog("未找到service, error code \(err)")
        return nil
    }
    
    var service = IOIteratorNext(iter)
    while service != 0 {
        let info = IODisplayCreateInfoDictionary(service, IOOptionBits(options)).takeRetainedValue()
            as Dictionary as [AnyHashable: Any]
        
        guard let cfVendorID = info[kDisplayVendorID] as! CFNumber?,
            let cfProductID = info[kDisplayProductID] as! CFNumber? else {
                NSLog("无效的id")
                continue
        }
        
        var vendorID: CFIndex = 0, productID: CFIndex = 0
        guard CFNumberGetValue(cfVendorID, .cfIndexType, &vendorID) &&
            CFNumberGetValue(cfProductID, .cfIndexType, &productID) else {
                continue
        }
        
        if UInt32(vendorID) == CGDisplayVendorNumber(displayID) &&
            UInt32(productID) == CGDisplayModelNumber(displayID) {
            return info
        }
        
        service = IOIteratorNext(iter)
    }
    
    return nil
}
