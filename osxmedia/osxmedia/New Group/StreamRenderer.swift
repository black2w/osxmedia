//
//  StreamRenderer.swift
//  osxmedia
//
//  Created by black2w on 2021/8/22.
//

import AVFoundation
import Foundation
#if canImport(AppKit)
import AppKit
#endif

protocol StreamRenderer: AnyObject {
    var orientation: AVCaptureVideoOrientation { get set }
    var position: AVCaptureDevice.Position { get set }
    
    var displayImage: CIImage? { get set }
    var videoFormatDescription: CMVideoFormatDescription? { get }

    func render(image: CIImage?)
    func attachStream(_ stream: Stream?)
}

extension StreamRenderer where Self: NSView {
    func render(image: CIImage?) {
        if Thread.isMainThread {
            displayImage = image
            #if os(macOS)
            self.needsDisplay = true
            #else
            self.setNeedsDisplay()
            #endif
        } else {
            DispatchQueue.main.async {
                self.render(image: image)
            }
        }
    }
}
