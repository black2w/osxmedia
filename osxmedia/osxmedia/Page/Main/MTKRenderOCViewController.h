//
//  MTKRenderOCViewController.h
//  osxmedia
//
//  Created by black2w on 2021/8/23.
//
@import MetalKit;
@import GLKit;
@import AVFoundation;
@import Cocoa;

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTKRenderOCViewController : NSViewController {
    
}

- (void)render:(CMSampleBufferRef)sampleBuffer;

@end

NS_ASSUME_NONNULL_END
