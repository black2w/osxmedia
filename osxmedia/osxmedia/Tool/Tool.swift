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
    class func showSaveImagePanel(imageData: NSData?, fileName: NSString,saveResult: @escaping (Bool) -> Void) -> Void {
        let savePanel = NSSavePanel()
        savePanel.title = NSLocalizedString("Save Image", comment: "")
        savePanel.prompt = NSLocalizedString("Save", comment: "")
        savePanel.nameFieldLabel = NSLocalizedString("File Name", comment: "")
        savePanel.nameFieldStringValue = fileName as String
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
    
    
    //获取当前时间字符串
   class func currentTime() -> String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "YYYY-MM-dd HH:mm:ss"// 自定义时间格式
        // GMT时间 转字符串，直接是系统当前时间
        return dateformatter.string(from: Date())
   }


    

    // CMSampleBufferRef –> CVImageBufferRef –> CIImage –> NSCIImageRep –> NSImage -> NSData
    class func getDataFromCMSampleBuffer(sampleBuffer: CMSampleBuffer) -> NSData? {
        if CMSampleBufferDataIsReady(sampleBuffer),
            let pixelBuffer = CMSampleBufferGetImageBuffer (sampleBuffer) {
            let height = CVPixelBufferGetHeight(pixelBuffer)
            let width = CVPixelBufferGetWidth(pixelBuffer)
            let ciImage: CIImage! = CIImage(cvImageBuffer: pixelBuffer)
            
            let imageRef: NSCIImageRep! = NSCIImageRep(ciImage: ciImage)
            let nsImage: NSImage! = NSImage.init(size: NSSize(width: width, height: height))
            nsImage.addRepresentation(imageRef)

            
            let imageRep = NSBitmapImageRep(data: nsImage.tiffRepresentation!)
            let pngData = imageRep?.representation(using: .jpeg, properties: [:])
            
            return pngData as NSData?
        } else {
            return nil
        }
    }
    
    class func convertCMBuffer2Nsdata(sampleBuffer: CMSampleBuffer) -> NSData? {
        return nil
    }
    
    class func jpegRepresentationOfImage(image: CIImage) -> NSData? {
        return nil
    }
    
    
    
}


