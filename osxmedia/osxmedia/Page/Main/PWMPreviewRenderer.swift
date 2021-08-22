//
//  PWMPreviewRenderer.swift
//  PreviewWithMetal
//
//  Created by SXC on 2018/7/7.
//  Copyright © 2018年 sxc. All rights reserved.
//

import Cocoa
import MetalKit
import AVFoundation


class PWMPreviewRenderer: NSObject, MTKViewDelegate {

    var device: MTLDevice
    var commandQueue: MTLCommandQueue
    // render pass
    var renderPipelineState: MTLRenderPipelineState
    var vertexBuffer: MTLBuffer
    var rgbTexture: MTLTexture
    
    // compute pass
    var textureCache: CVMetalTextureCache?
    var luminance: MTLTexture?
    var chroma: MTLTexture?
    var convertMatrix: float3x3
    var yuv2rgbComputePipeline: MTLComputePipelineState
    
    // signals to sync texture render/update
    let textureRenderSignal = DispatchSemaphore(value: 0)
    let textureUpdateSignal = DispatchSemaphore(value: 1)
    
    init(device: MTLDevice, for renderView: MTKView) {
        self.device = device
        self.commandQueue = device.makeCommandQueue()!
        let library = device.makeDefaultLibrary()!
        
        // setup compute pipeline
        let yuv2rgbFunc = library.makeFunction(name: "yuvToRGB")!
        yuv2rgbComputePipeline = try! device.makeComputePipelineState(function: yuv2rgbFunc)
        CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, device, nil, &textureCache)
        convertMatrix = float3x3(float3(1.164, 1.164, 1.164),
                                 float3(0, -0.231, 2.112),
                                 float3(1.793, -0.533, 0))
        
        // setup render pipeline
        let vertexFunc = library.makeFunction(name: "vertexShader")!
        let fragmentFunc = library.makeFunction(name: "fragmentShader")!
        let pipelineDesc = MTLRenderPipelineDescriptor()
        pipelineDesc.fragmentFunction = fragmentFunc
        pipelineDesc.vertexFunction = vertexFunc
        pipelineDesc.colorAttachments[0].pixelFormat = renderView.colorPixelFormat
        renderPipelineState = try! device.makeRenderPipelineState(descriptor: pipelineDesc)
        
        let vertices = [PWMVertex(position: vector_float2(-1, -1), coordinate: vector_float2(1, 1)),
                        PWMVertex(position: vector_float2(1, -1), coordinate: vector_float2(1, 0)),
                        PWMVertex(position: vector_float2(-1, 1), coordinate: vector_float2(0, 1)),
                        PWMVertex(position: vector_float2(1, 1), coordinate: vector_float2(0, 0))]
        vertexBuffer = device.makeBuffer(length: MemoryLayout<PWMVertex>.size * vertices.count, options: MTLResourceOptions.storageModeShared)!
        memcpy(vertexBuffer.contents(), vertices, MemoryLayout<PWMVertex>.size * vertices.count)
        
        let textureDesc = MTLTextureDescriptor()
        textureDesc.width = 1280
        textureDesc.height = 720
        textureDesc.pixelFormat = .bgra8Unorm
        textureDesc.usage = MTLTextureUsage(rawValue: MTLTextureUsage.shaderRead.rawValue | MTLTextureUsage.shaderWrite.rawValue)
        rgbTexture = device.makeTexture(descriptor: textureDesc)!
        
        super.init()
        renderView.delegate = self
    }
    
    func updateTexture(sampleBuffer: CMSampleBuffer) {
        guard textureUpdateSignal.wait(timeout: .now()) == .success else {
            return
        }
        
        let imagePixel = CMSampleBufferGetImageBuffer(sampleBuffer)!
        let yWidth = CVPixelBufferGetWidthOfPlane(imagePixel, 0)
        let yHeight = CVPixelBufferGetHeightOfPlane(imagePixel, 0)
        
        let uvWidth = CVPixelBufferGetWidthOfPlane(imagePixel, 1)
        let uvHeight = CVPixelBufferGetHeightOfPlane(imagePixel, 1)
        
        CVPixelBufferLockBaseAddress(imagePixel, CVPixelBufferLockFlags(rawValue: 0))
        var yTexture: CVMetalTexture?
        var uvTexture: CVMetalTexture?
        CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache!, imagePixel, nil, .r8Unorm, yWidth, yHeight, 0, &yTexture)
        CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache!, imagePixel, nil, .rg8Unorm, uvWidth, uvHeight, 1, &uvTexture)
        
        CVPixelBufferUnlockBaseAddress(imagePixel, CVPixelBufferLockFlags(rawValue: 0))
        guard yTexture != nil && uvTexture != nil else {
            return
        }
        
        // Get MTLTexture instance
        luminance = CVMetalTextureGetTexture(yTexture!)
        chroma = CVMetalTextureGetTexture(uvTexture!)
        
        textureRenderSignal.signal()
    }
    
    func draw(in view: MTKView) {
        
        guard textureRenderSignal.wait(timeout: .now()) == .success else {
            return
        }
        
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            return
        }
        
        guard let computeEncoder = commandBuffer.makeComputeCommandEncoder() else {
            return
        }
        
        // compute pass
        computeEncoder.setComputePipelineState(yuv2rgbComputePipeline)
        computeEncoder.setTexture(luminance, index: 0)
        computeEncoder.setTexture(chroma, index: 1)
        computeEncoder.setTexture(rgbTexture, index: 2)
        computeEncoder.setBytes(&convertMatrix, length: MemoryLayout<float3x3>.size, index: 0)
        
        let width = rgbTexture.width
        let height = rgbTexture.height
        
        let groupSize = 32
        let groupCountW = (width + groupSize) / groupSize - 1
        let groupCountH = (height + groupSize) / groupSize - 1
        computeEncoder.dispatchThreadgroups(MTLSize(width: groupCountW, height: groupCountH, depth: 1),
                                            threadsPerThreadgroup: MTLSize(width: groupSize, height: groupSize, depth: 1))
        computeEncoder.endEncoding()
        
        // render pass
        guard let renderPassDesc = view.currentRenderPassDescriptor else {
            return
        }
        
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDesc) else {
            return
        }

        renderEncoder.setRenderPipelineState(renderPipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.setFragmentTexture(rgbTexture, index: 0)
        
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        renderEncoder.endEncoding()
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
        
        textureUpdateSignal.signal()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
}









