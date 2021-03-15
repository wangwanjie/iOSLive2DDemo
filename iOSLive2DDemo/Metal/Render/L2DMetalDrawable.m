//
//  L2DMetalDrawable.m
//  iOSLive2DDemo
//
//  Created by VanJay on 2020/12/19.
//

#import "L2DMetalDrawable.h"

@interface L2DMetalDrawable ()
@end

@implementation L2DMetalDrawable

- (instancetype)init {
    self = [super init];
    if (self) {
        _drawableIndex = 0;
        _vertexCount = 0;
        _indexCount = 0;
        _textureIndex = 0;
        _maskCount = 0;
        _cullingMode = false;
        _blendMode = L2DBlendModeNormal;
        _opacity = 1.0;
        _visibility = true;
        _masks = [NSMutableArray array];
    }
    return self;
}
@end
