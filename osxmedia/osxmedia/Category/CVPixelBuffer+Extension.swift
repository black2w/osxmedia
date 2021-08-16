//
//  CVPixelBuffer+Extension.swift
//  osxmedia
//
//  Created by black2w on 2021/8/12.
//

import Foundation
import AVFoundation
import Accelerate


extension CVPixelBuffer {

  /**
   Returns thumbnail by cropping pixel buffer to biggest square and scaling the cropped image to
   model dimensions.
   */
  func centerThumbnail(ofSize size: CGSize ) -> CVPixelBuffer? {

    let imageWidth = CVPixelBufferGetWidth(self)
    let imageHeight = CVPixelBufferGetHeight(self)
    let pixelBufferType = CVPixelBufferGetPixelFormatType(self)

//    assert(pixelBufferType == kCVPixelFormatType_32BGRA)

    let inputImageRowBytes = CVPixelBufferGetBytesPerRow(self)
    let imageChannels = 4

    let thumbnailSize = min(imageWidth, imageHeight)
    CVPixelBufferLockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 0))

    var originX = 0
    var originY = 0

    if imageWidth > imageHeight {
      originX = (imageWidth - imageHeight) / 2
    }
    else {
      originY = (imageHeight - imageWidth) / 2
    }

    // Finds the biggest square in the pixel buffer and advances rows based on it.
    guard let inputBaseAddress = CVPixelBufferGetBaseAddress(self)?.advanced(
        by: originY * inputImageRowBytes + originX * imageChannels) else {
      return nil
    }

    // Gets vImage Buffer from input image
    var inputVImageBuffer = vImage_Buffer(
        data: inputBaseAddress, height: UInt(thumbnailSize), width: UInt(thumbnailSize),
        rowBytes: inputImageRowBytes)

    let thumbnailRowBytes = Int(size.width) * imageChannels
    guard  let thumbnailBytes = malloc(Int(size.height) * thumbnailRowBytes) else {
      return nil
    }

    // Allocates a vImage buffer for thumbnail image.
    var thumbnailVImageBuffer = vImage_Buffer(data: thumbnailBytes, height: UInt(size.height), width: UInt(size.width), rowBytes: thumbnailRowBytes)

    // Performs the scale operation on input image buffer and stores it in thumbnail image buffer.
    let scaleError = vImageScale_ARGB8888(&inputVImageBuffer, &thumbnailVImageBuffer, nil, vImage_Flags(0))

    CVPixelBufferUnlockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 0))

    guard scaleError == kvImageNoError else {
      return nil
    }

    let releaseCallBack: CVPixelBufferReleaseBytesCallback = {mutablePointer, pointer in

      if let pointer = pointer {
        free(UnsafeMutableRawPointer(mutating: pointer))
      }
    }

    var thumbnailPixelBuffer: CVPixelBuffer?

    // Converts the thumbnail vImage buffer to CVPixelBuffer
    let conversionStatus = CVPixelBufferCreateWithBytes(
        nil, Int(size.width), Int(size.height), pixelBufferType, thumbnailBytes,
        thumbnailRowBytes, releaseCallBack, nil, nil, &thumbnailPixelBuffer)

    guard conversionStatus == kCVReturnSuccess else {

      free(thumbnailBytes)
      return nil
    }

    return thumbnailPixelBuffer
  }

}

extension CVPixelBuffer {
    func copy() -> CVPixelBuffer {
        precondition(CFGetTypeID(self) == CVPixelBufferGetTypeID(), "copy() cannot be called on a non-CVPixelBuffer")

        let ioSurfaceProps = [
            "IOSurfaceOpenGLESFBOCompatibility": true as CFBoolean,
            "IOSurfaceOpenGLESTextureCompatibility": true as CFBoolean,
            "IOSurfaceCoreAnimationCompatibility": true as CFBoolean
        ] as CFDictionary

        let options = [
            String(kCVPixelBufferMetalCompatibilityKey): true as CFBoolean,
            String(kCVPixelBufferIOSurfacePropertiesKey): ioSurfaceProps
        ] as CFDictionary

        var _copy : CVPixelBuffer?
        CVPixelBufferCreate(
            nil,
            CVPixelBufferGetWidth(self),
            CVPixelBufferGetHeight(self),
            CVPixelBufferGetPixelFormatType(self),
            options,
            &_copy)

        guard let copy = _copy else { fatalError() }

        CVBufferPropagateAttachments(self as CVBuffer, copy as CVBuffer)

        CVPixelBufferLockBaseAddress(self, CVPixelBufferLockFlags.readOnly)
        CVPixelBufferLockBaseAddress(copy, CVPixelBufferLockFlags(rawValue: 0))

        let copyBaseAddress = CVPixelBufferGetBaseAddress(copy)
        let currBaseAddress = CVPixelBufferGetBaseAddress(self)

        memcpy(copyBaseAddress, currBaseAddress, CVPixelBufferGetDataSize(self))

        CVPixelBufferUnlockBaseAddress(copy, CVPixelBufferLockFlags(rawValue: 0))
        CVPixelBufferUnlockBaseAddress(self, CVPixelBufferLockFlags.readOnly)

        // let's make sure they have the same average color
//        let originalImage = CIImage(cvPixelBuffer: self)
//        let copiedImage = CIImage(cvPixelBuffer: copy)
//
//        let averageColorOriginal = originalImage.averageColour()
//        let averageColorCopy = copiedImage.averageColour()
//
//        assert(averageColorCopy == averageColorOriginal)
//        debugPrint("average frame color: \(averageColorCopy)")

        return copy
    }
}
