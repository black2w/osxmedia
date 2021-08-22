//
//  MTKRenderViewController.swift
//  osxmedia
//
//  Created by black2w on 2021/8/22.
//

import Cocoa
import MetalKit


class MTKRenderViewController: BaseViewController {


    @IBOutlet var mtkView: MTKView!
    var renderer: PWMPreviewRenderer!

    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.setupMetal()
    }
    
    func setupMetal() -> Void {
        let device = MTLCreateSystemDefaultDevice()!
        renderer = PWMPreviewRenderer(device: device, for: mtkView)
    }

    func render(samplebuffer: CMSampleBuffer) -> Void {
        renderer.updateTexture(sampleBuffer: samplebuffer)
    }
    
}
