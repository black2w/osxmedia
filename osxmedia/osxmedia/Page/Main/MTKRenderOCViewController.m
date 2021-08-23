//
//  MTKRenderOCViewController.m
//  osxmedia
//
//  Created by black2w on 2021/8/23.
//



#import "MTKRenderOCViewController.h"
#import <MetalPerformanceShaders/MetalPerformanceShaders.h>
#import "ShaderTypes.h"


@interface MTKRenderOCViewController () <MTKViewDelegate>{
    
}

// view
@property (nonatomic, strong) IBOutlet MTKView *mtkView;
@property (nonatomic, assign) CVMetalTextureCacheRef textureCache; //output

@property (nonatomic, assign) CGSize viewportSize;
@property (nonatomic, strong) id<MTLRenderPipelineState> renderPipelineState;
@property (nonatomic, strong) id<MTLComputePipelineState> computePipelineState;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, strong) id<MTLTexture> sourceTexture;
@property (nonatomic, strong) id<MTLTexture> destTexture;
;
;
@property (nonatomic, strong) id<MTLBuffer> vertices;
@property (nonatomic, assign) NSUInteger numVertices;
@property (nonatomic, assign) MTLSize groupSize;
@property (nonatomic, assign) MTLSize groupCount;

@property (nonatomic, assign) CGFloat originWidth;
@property (nonatomic, assign) CGFloat originHeight;

@end

@implementation MTKRenderOCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.wantsLayer = true;
//    self.view.layer.backgroundColor = NSColor.blueColor.CGColor;
    // Do view setup here.
    // 设置Metal 相关
}

- (void)defaultSetting{
    [self setupMetal];
    [self customInit];
}

- (void)setupMetal {
    self.mtkView.device = MTLCreateSystemDefaultDevice();
    self.mtkView.delegate = self;
    self.mtkView.framebufferOnly = NO; // 允许读写操作
    CVMetalTextureCacheCreate(NULL, NULL, self.mtkView.device, NULL, &_textureCache);
    self.viewportSize = CGSizeMake(self.originWidth, self.originHeight);
}

- (void)customInit {
    [self setupPipeline];
    [self setupVertex];
    [self setupTexture];
    [self setupThreadGroup];
}

// 设置渲染管道和计算管道
-(void)setupPipeline {
    id<MTLLibrary> defaultLibrary = [self.mtkView.device newDefaultLibrary]; // .metal
    id<MTLFunction> vertexFunction = [defaultLibrary newFunctionWithName:@"vertexShader"]; // 顶点shader，vertexShader是函数名
    id<MTLFunction> fragmentFunction = [defaultLibrary newFunctionWithName:@"samplingShader"]; // 片元shader，samplingShader是函数名
    id<MTLFunction> kernelFunction = [defaultLibrary newFunctionWithName:@"grayKernel"];
    
    MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineStateDescriptor.vertexFunction = vertexFunction;
    pipelineStateDescriptor.fragmentFunction = fragmentFunction;
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = self.mtkView.colorPixelFormat;
    // 创建图形渲染管道，耗性能操作不宜频繁调用
    self.renderPipelineState = [self.mtkView.device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor
                                                                                   error:NULL];
    // 创建计算管道，耗性能操作不宜频繁调用
    self.computePipelineState = [self.mtkView.device newComputePipelineStateWithFunction:kernelFunction
                                                                                   error:NULL];
    // CommandQueue是渲染指令队列，保证渲染指令有序地提交到GPU
    self.commandQueue = [self.mtkView.device newCommandQueue];
}

- (void)setupVertex {
    const LYVertex quadVertices[] =
    {   // 顶点坐标，分别是x、y、z、w；    纹理坐标，x、y；
        { {  1, -1 / self.viewportSize.height * self.viewportSize.width, 0.0, 1.0 },  { 1.f, 1.f } },
        { { -1, -1 / self.viewportSize.height * self.viewportSize.width, 0.0, 1.0 },  { 0.f, 1.f } },
        { { -1,  1 / self.viewportSize.height * self.viewportSize.width, 0.0, 1.0 },  { 0.f, 0.f } },
        
        { {  1, -1 / self.viewportSize.height * self.viewportSize.width, 0.0, 1.0 },  { 1.f, 1.f } },
        { { -1,  1 / self.viewportSize.height * self.viewportSize.width, 0.0, 1.0 },  { 0.f, 0.f } },
        { {  1,  1 / self.viewportSize.height * self.viewportSize.width, 0.0, 1.0 },  { 1.f, 0.f } },
    };
    self.vertices = [self.mtkView.device newBufferWithBytes:quadVertices
                                                     length:sizeof(quadVertices)
                                                    options:MTLResourceStorageModeShared]; // 创建顶点缓存
    self.numVertices = sizeof(quadVertices) / sizeof(LYVertex); // 顶点个数
}

- (void)setupTexture {
    // 纹理描述符
    MTLTextureDescriptor *textureDescriptor = [[MTLTextureDescriptor alloc] init];
    textureDescriptor.pixelFormat = MTLPixelFormatRGBA8Unorm; // 图片的格式要和数据一致
    textureDescriptor.width = self.originWidth;
    textureDescriptor.height = self.originHeight;
    textureDescriptor.usage = MTLTextureUsageShaderRead; // 原图片只需要读取
    textureDescriptor.usage = MTLTextureUsageShaderWrite | MTLTextureUsageShaderRead; // 目标纹理在compute管道需要写，在render管道需要读
    self.destTexture = [self.mtkView.device newTextureWithDescriptor:textureDescriptor];
}

- (void)setupThreadGroup {
    self.groupSize = MTLSizeMake(16, 16, 1); // 太大某些GPU不支持，太小效率低；
    _groupCount.width  = self.originWidth / self.groupSize.width;
    _groupCount.height = self.originHeight / self.groupSize.height;
    _groupCount.depth = 1; // 我们是2D纹理，深度设为1
}




#pragma mark - delegate

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {
//    self.viewportSize = CGSizeMake(size.width, size.height);
//    if (size.width != self.originWidth) {
//        self.originWidth = size.width;
//        self.originHeight = size.height;
//        [self defaultSetting];
//    }
}

- (void)drawInMTKView:(MTKView *)view {
    // 每次渲染都要单独创建一个CommandBuffer
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    
    {
        // 创建计算指令的编码器
        id<MTLComputeCommandEncoder> computeEncoder = [commandBuffer computeCommandEncoder];
        // 设置计算管道，以调用shaders.metal中的内核计算函数
        [computeEncoder setComputePipelineState:self.computePipelineState];
        // 输入纹理
        [computeEncoder setTexture:self.sourceTexture
                           atIndex:LYFragmentTextureIndexTextureSource];
        // 输出纹理
        [computeEncoder setTexture:self.destTexture
                           atIndex:LYFragmentTextureIndexTextureDest];
        // 计算区域
        [computeEncoder dispatchThreadgroups:self.groupCount
                       threadsPerThreadgroup:self.groupSize];
        // 调用endEncoding释放编码器，下个encoder才能创建
        [computeEncoder endEncoding];
    }
    
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    // MTLRenderPassDescriptor描述一系列attachments的值，类似GL的FrameBuffer；同时也用来创建MTLRenderCommandEncoder
    if(renderPassDescriptor != nil)
    {
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 0.5, 0.5, 1.0f); // 设置默认颜色
        id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor]; //编码绘制指令的Encoder
        [renderEncoder setViewport:(MTLViewport){0.0, 0.0, self.viewportSize.width, self.viewportSize.height, -1.0, 1.0 }]; // 设置显示区域
        [renderEncoder setRenderPipelineState:self.renderPipelineState]; // 设置渲染管道，以保证顶点和片元两个shader会被调用
        
        [renderEncoder setVertexBuffer:self.vertices
                                offset:0
                               atIndex:0]; // 设置顶点缓存
        
        [renderEncoder setFragmentTexture:self.destTexture
                                  atIndex:0]; // 设置纹理
        
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle
                          vertexStart:0
                          vertexCount:self.numVertices]; // 绘制
        
        [renderEncoder endEncoding]; // 结束
        
        [commandBuffer presentDrawable:view.currentDrawable]; // 显示
    }
    
    [commandBuffer commit]; // 提交；
    
    
}

- (void)render:(CMSampleBufferRef)sampleBuffer {
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    size_t width = CVPixelBufferGetWidth(pixelBuffer);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);
    
    if (width != self.originWidth) {
        self.originWidth = width;
        self.originHeight = height;
        //第一次数据不一样，丢弃。为了重置相关参数
        [self defaultSetting];
        return;
    }
    
    
    
    CVMetalTextureRef tmpTexture = NULL;
    // 如果MTLPixelFormatBGRA8Unorm和摄像头采集时设置的颜色格式不一致，则会出现图像异常的情况；
    CVReturn status = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, self.textureCache, pixelBuffer, NULL, MTLPixelFormatBGRA8Unorm, width, height, 0, &tmpTexture);
    if(status == kCVReturnSuccess)
    {
        self.mtkView.drawableSize = CGSizeMake(width, height);
        self.sourceTexture = CVMetalTextureGetTexture(tmpTexture);
        CFRelease(tmpTexture);
    }
}


@end
