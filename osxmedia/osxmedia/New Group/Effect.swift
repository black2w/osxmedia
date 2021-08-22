//
//  Effect.swift
//  osxmedia
//
//  Created by black2w on 2021/8/22.
//

import Foundation

import AVFoundation
import CoreImage
import Foundation

class BaseEffect: NSObject {
    open var ciContext: CIContext?

    open func execute(_ image: CIImage, info: CMSampleBuffer?) -> CIImage {
        image
    }
}

final class Effect: BaseEffect {
    let filter: CIFilter? = CIFilter(name: "CIColorMonochrome")

    override func execute(_ image: CIImage, info: CMSampleBuffer?) -> CIImage {
        guard let filter: CIFilter = filter else {
            return image
        }
        filter.setValue(image, forKey: "inputImage")
        filter.setValue(CIColor(red: 0.75, green: 0.75, blue: 0.75), forKey: "inputColor")
        filter.setValue(1.0, forKey: "inputIntensity")
        return filter.outputImage!
    }
}

