//
//  Tool.swift
//  osxmedia
//
//  Created by black2w on 2021/7/6.
//

import Foundation
import Cocoa
import AVFoundation
import VideoToolbox

class Tool: NSObject {
    
    //根据NSView生成image,截图方式
    class func viewToImage(view: NSView) -> NSImage? {
        
        return nil
    }
    
    
    //显示保存panel
    class func showSaveImagePanel(imageData: NSData?, saveResult: @escaping (Bool) -> Void) -> Void {
        let savePanel = NSSavePanel()
        savePanel.title = "保存图片"
        savePanel.prompt = "保存"
        savePanel.nameFieldLabel = "文件名"
        savePanel.nameFieldStringValue = "example.png"
        savePanel.canSelectHiddenExtension = true
        savePanel.allowedFileTypes = ["jpg", "jpeg"]

        let result = savePanel.runModal()
        switch result {
            case .OK:
                guard let saveURL = savePanel.url else { return }
                if let writeData = imageData {
                    writeData.write(to: saveURL, atomically: true)
                } else {
                    let alert = NSAlert()
                    alert.messageText = "Error"
                    alert.informativeText = "Failed to save image."
                    alert.alertStyle = .informational
                    alert.addButton(withTitle: "OK")
                    alert.runModal()
                }
                
                saveResult(true)
            case .cancel:
                print("用户取消保存")
                saveResult(true)
            default:
                print("未知选择")
                saveResult(true)

        }
    }
    
    
    
    // CMSampleBufferRef –> CVImageBufferRef –> CGContextRef –> CGImageRef –> UIImage
    class func getDataFromCMSampleBuffer(sampleBuffer: CMSampleBuffer) -> NSData? {
        if CMSampleBufferDataIsReady(sampleBuffer),
            let pixelBuffer = CMSampleBufferGetImageBuffer (sampleBuffer) {
            let ciImage: CIImage! = CIImage(cvImageBuffer: pixelBuffer)
//            let image: NSImage = NSImage.init(c)
//            let data: NSData! = image.tiffRepresentation as! NSData
//            return data
            return nil
        } else {
            return nil
        }
    }
}

