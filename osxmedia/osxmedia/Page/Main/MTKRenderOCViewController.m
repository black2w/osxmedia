//
//  MTKRenderOCViewController.m
//  osxmedia
//
//  Created by black2w on 2021/8/23.
//



#import "MTKRenderOCViewController.h"
#import <MetalPerformanceShaders/MetalPerformanceShaders.h>


@interface MTKRenderOCViewController () <MTKViewDelegate>{
    
}

// view
@property (nonatomic, strong) IBOutlet MTKView *mtkView;
@property (nonatomic, assign) CVMetalTextureCacheRef textureCache; //output
// data
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, strong) id<MTLTexture> texture;
@end

@implementation MTKRenderOCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.wantsLayer = true;
    self.view.layer.backgroundColor = NSColor.blueColor.CGColor;
    // Do view setup here.
    // 设置Metal 相关
    [self setupMetal];
}

- (void)setupMetal {
//    self.mtkView = [[MTKView alloc] initWithFrame:self.view.bounds];
    self.mtkView.device = MTLCreateSystemDefaultDevice();
//    [self.view insertSubview:self.mtkView atIndex:0];
    self.mtkView.delegate = self;
    self.mtkView.framebufferOnly = NO; // 允许读写操作
    //    self.mtkView.transform = CGAffineTransformMakeRotation(M_PI / 2);
    self.commandQueue = [self.mtkView.device newCommandQueue];
    CVMetalTextureCacheCreate(NULL, NULL, self.mtkView.device, NULL, &_textureCache);
}

#pragma mark - delegate

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {
    
}

- (void)drawInMTKView:(MTKView *)view {
    if (self.texture) {
        id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer]; // 创建指令缓冲
        id<MTLTexture> drawingTexture = view.currentDrawable.texture; // 把MKTView作为目标纹理
        
        MPSImageGaussianBlur *filter = [[MPSImageGaussianBlur alloc] initWithDevice:self.mtkView.device sigma:1]; // 这里的sigma值可以修改，sigma值越高图像越模糊
        [filter encodeToCommandBuffer:commandBuffer sourceTexture:self.texture destinationTexture:drawingTexture]; // 把摄像头返回图像数据的原始数据
        
        [commandBuffer presentDrawable:view.currentDrawable]; // 展示数据
        [commandBuffer commit];
        
        self.texture = NULL;
    }
}

- (void)render:(CMSampleBufferRef)sampleBuffer {
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    size_t width = CVPixelBufferGetWidth(pixelBuffer);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);
    
    CVMetalTextureRef tmpTexture = NULL;
    // 如果MTLPixelFormatBGRA8Unorm和摄像头采集时设置的颜色格式不一致，则会出现图像异常的情况；
    CVReturn status = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, self.textureCache, pixelBuffer, NULL, MTLPixelFormatBGRA8Unorm, width, height, 0, &tmpTexture);
    if(status == kCVReturnSuccess)
    {
        self.mtkView.drawableSize = CGSizeMake(width, height);
        self.texture = CVMetalTextureGetTexture(tmpTexture);
        CFRelease(tmpTexture);
    }
}


@end
