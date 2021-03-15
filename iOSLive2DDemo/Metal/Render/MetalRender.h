//
//  MetalRender.h
//  iOSLive2DDemo
//
//  Created by VanJay on 2020/12/19.
//

#import "L2DBufferIndex.h"
#import "L2DUserModel.h"
#import "MetalDrawable.h"
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <UIKit/UIKit.h>
#import <simd/simd.h>
#import <string.h>

NS_ASSUME_NONNULL_BEGIN

@class MetalRender;

@protocol MetalRenderDelegate <NSObject>
@required

/// 用于外部接收刷新事件
/// @param renderer 渲染器
/// @param duration 时长
- (void)rendererUpdateWithRender:(MetalRender *)renderer duration:(NSTimeInterval)duration;
@end

@interface MetalRender : NSObject
@property (nonatomic, weak) id<MetalRenderDelegate> delegate;
@property (nonatomic, strong) L2DUserModel *model;

/// Model rendering origin, in normalized device coordinate (NDC).
///
/// Default is `(0,0)`.
///
/// Set this property will reset `transform` matrix.
@property (nonatomic, assign) CGPoint origin;

/// Model rendering scale.
///
/// Default is `1.0`.
///
/// Set this property will reset `transform` matrix.
@property (nonatomic, assign) CGFloat scale;

/// Transform matrix of model.
///
/// Note that set `origin` or `scale` will reset transform matrix.
@property (nonatomic, assign) matrix_float4x4 transform;

/// 背景色
@property (nonatomic, assign) MTLClearColor clearColor;

/// 已经创建了 transformBuffer
@property (nonatomic, copy) void (^didCreatedTransformBuffer)(void);

/// 默认渲染人物高度与画布高度比例
- (float)defaultRenderScale;
@end

@interface MetalRender (Renderer)

- (void)startWithView:(MTKView *)view;

- (void)drawableSizeWillChange:(MTKView *)view size:(CGSize)size;

- (void)update:(NSTimeInterval)time;

- (void)beginRenderWithTime:(NSTimeInterval)time viewPort:(MTLViewport)viewPort commandBuffer:(id<MTLCommandBuffer>)commandBuffer passDescriptor:(MTLRenderPassDescriptor *)passDescriptor;

@end

NS_ASSUME_NONNULL_END
