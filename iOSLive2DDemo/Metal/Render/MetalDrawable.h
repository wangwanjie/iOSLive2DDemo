//
//  MetalDrawable.h
//  iOSLive2DDemo
//
//  Created by VanJay on 2020/12/19.
//

#import "L2DModel.h"
#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MetalDrawable : NSObject

/// Index for buffer reference.
@property (nonatomic, assign) int drawableIndex;

/// Number of vertex.
@property (nonatomic, assign) NSInteger vertexCount;

/// Number of draw index.
@property (nonatomic, assign) NSInteger indexCount;

// Textures.
/// Which texture will use for drawable.
@property (nonatomic, assign) NSInteger textureIndex;

// Constant flags.
@property (nonatomic, assign) NSInteger maskCount;

// Constant flags.
/// Culling mode. `True` if culling enable.
@property (nonatomic, assign) BOOL cullingMode;

/// Blend mode.
@property (nonatomic, assign) L2DBlendMode blendMode;

/// Vertex buffers. Create by `MetalRender`.
@property (nonatomic, nullable, strong) id<MTLBuffer> vertexPositionBuffer;

/// Vertex UV buffers. Create by `MetalRender`.
@property (nonatomic, nullable, strong) id<MTLBuffer> vertexTextureCoordinateBuffer;

/// Draw index buffers. Create by `MetalRender`.
@property (nonatomic, nullable, strong) id<MTLBuffer> vertexIndexBuffer;

/// Masks.
@property (nonatomic, strong) NSArray *masks;

/// Mask texture. Create by `MetalRender`.
@property (nonatomic, strong) id<MTLTexture> maskTexture;

/// Opacity.
@property (nonatomic, assign) float opacity;

/// Opacity buffer. Create by `MetalRender`.
@property (nonatomic, strong) id<MTLBuffer> opacityBuffer;

/// Visibility.
@property (nonatomic, assign) BOOL visibility;
@end

NS_ASSUME_NONNULL_END
