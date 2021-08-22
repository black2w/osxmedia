//
//  CMSampleBUffer+Extension.swift
//  osxmedia
//
//  Created by black2w on 2021/8/22.
//

import CoreMedia
import Accelerate

extension CMSampleBuffer {
    var isNotSync: Bool {
        get {
            getAttachmentValue(for: kCMSampleAttachmentKey_NotSync) ?? false
        }
        set {
            setAttachmentValue(for: kCMSampleAttachmentKey_NotSync, value: newValue)
        }
    }

    var isValid: Bool {
        CMSampleBufferIsValid(self)
    }

    
    var dataBuffer: CMBlockBuffer? {
        get {
            CMSampleBufferGetDataBuffer(self)
        }
        set {
            _ = newValue.map {
                CMSampleBufferSetDataBuffer(self, newValue: $0)
            }
        }
    }

    
    var imageBuffer: CVImageBuffer? {
        CMSampleBufferGetImageBuffer(self)
    }

    
    var numSamples: CMItemCount {
        CMSampleBufferGetNumSamples(self)
    }

    var duration: CMTime {
        CMSampleBufferGetDuration(self)
    }

    var formatDescription: CMFormatDescription? {
        CMSampleBufferGetFormatDescription(self)
    }

    var decodeTimeStamp: CMTime {
        CMSampleBufferGetDecodeTimeStamp(self)
    }

    var presentationTimeStamp: CMTime {
        CMSampleBufferGetPresentationTimeStamp(self)
    }

    // swiftlint:disable discouraged_optional_boolean
    @inline(__always)
    private func getAttachmentValue(for key: CFString) -> Bool? {
        guard
            let attachments = CMSampleBufferGetSampleAttachmentsArray(self, createIfNecessary: false) as? [[CFString: Any]],
            let value = attachments.first?[key] as? Bool else {
            return nil
        }
        return value
    }

    @inline(__always)
    private func setAttachmentValue(for key: CFString, value: Bool) {
        guard
            let attachments: CFArray = CMSampleBufferGetSampleAttachmentsArray(self, createIfNecessary: true), 0 < CFArrayGetCount(attachments) else {
            return
        }
        let attachment = unsafeBitCast(CFArrayGetValueAtIndex(attachments, 0), to: CFMutableDictionary.self)
        CFDictionarySetValue(
            attachment,
            Unmanaged.passUnretained(key).toOpaque(),
            Unmanaged.passUnretained(value ? kCFBooleanTrue : kCFBooleanFalse).toOpaque()
        )
    }

    static var format = vImage_CGImageFormat(
        bitsPerComponent: 8,
        bitsPerPixel: 32,
        colorSpace: nil,
        bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.first.rawValue),
        version: 0,
        decode: nil,
        renderingIntent: .defaultIntent)

    public func reflectHorizontal() {
        if let imageBuffer: CVImageBuffer = self.imageBuffer {
            var sourceBuffer = vImage_Buffer()

            let inputCVImageFormat = vImageCVImageFormat_CreateWithCVPixelBuffer(imageBuffer).takeRetainedValue()

            vImageCVImageFormat_SetColorSpace(inputCVImageFormat, CGColorSpaceCreateDeviceRGB())

            var error = kvImageNoError

            error = vImageBuffer_InitWithCVPixelBuffer(&sourceBuffer,
                                                       &CMSampleBuffer.format,
                                                       imageBuffer,
                                                       inputCVImageFormat,
                                                       nil,
                                                       vImage_Flags(kvImageNoFlags))

            guard error == kvImageNoError else {
                return
            }
            defer {
                free(sourceBuffer.data)
            }

            var destinationBuffer = vImage_Buffer()

            error = vImageBuffer_Init(&destinationBuffer,
                                      sourceBuffer.height,
                                      sourceBuffer.width,
                                      CMSampleBuffer.format.bitsPerPixel,
                                      vImage_Flags(kvImageNoFlags))

            guard error == kvImageNoError else {
                return
            }
            defer {
                free(destinationBuffer.data)
            }

            error = vImageHorizontalReflect_ARGB8888(&sourceBuffer, &destinationBuffer, vImage_Flags(kvImageLeaveAlphaUnchanged))

            guard error == kvImageNoError else {
                return
            }

            let outputCVImageFormat = vImageCVImageFormat_CreateWithCVPixelBuffer(imageBuffer).takeRetainedValue()
            vImageCVImageFormat_SetColorSpace(outputCVImageFormat, CGColorSpaceCreateDeviceRGB())

            error = vImageBuffer_CopyToCVPixelBuffer(&destinationBuffer,
                                                     &CMSampleBuffer.format,
                                                     imageBuffer,
                                                     outputCVImageFormat,
                                                     nil,
                                                     vImage_Flags(kvImageNoFlags))
        }
    }
}

