//
//  L2DMatrix44Bridge.m
//  iOSLive2DDemo
//
//  Created by VanJay on 2021/3/15.
//

#import "L2DMatrix44Bridge.h"
#import <CubismFramework.hpp>
#import <Math/CubismMatrix44.hpp>

@interface L2DMatrix44Bridge () {
    Csm::CubismMatrix44 *_viewMatrix;
}
@end

@implementation L2DMatrix44Bridge
- (instancetype)init {
    self = [super init];
    if (self) {
        _viewMatrix = new Csm::CubismMatrix44();
    }
    return self;
}

- (void)dealloc {
    delete _viewMatrix;
}

+ (void)multiplyA:(float *)a b:(float *)b dst:(float *)dst {
    Csm::CubismMatrix44::Multiply(a, b, dst);
}

- (float *)getArray {
    return _viewMatrix->GetArray();
}

- (void)setMatrix:(float *)tr {
    _viewMatrix->SetMatrix(tr);
}

- (float)getScaleX {
    return _viewMatrix->GetScaleX();
}

- (float)getScaleY {
    return _viewMatrix->GetScaleY();
}

- (float)getTranslateX {
    return _viewMatrix->GetTranslateX();
}

- (float)getTranslateY {
    return _viewMatrix->GetTranslateY();
}

- (float)transformX:(float)src {
    return _viewMatrix->TransformX(src);
}

- (float)transformY:(float)src {
    return _viewMatrix->TransformY(src);
}

- (float)invertTransformX:(float)src {
    return _viewMatrix->InvertTransformX(src);
}

- (float)invertTransformY:(float)src {
    return _viewMatrix->InvertTransformY(src);
}

- (void)translateRelativeX:(float)x y:(float)y {
    _viewMatrix->TranslateRelative(x, y);
}

- (void)translateX:(float)x y:(float)y {
    _viewMatrix->Translate(x, y);
}

- (void)translateX:(float)x {
    _viewMatrix->TranslateX(x);
}

- (void)translateY:(float)y {
    _viewMatrix->TranslateY(y);
}

- (void)scaleRelativeX:(float)x y:(float)y {
    _viewMatrix->ScaleRelative(x, y);
}

- (void)scaleX:(float)x y:(float)y {
    _viewMatrix->Scale(x, y);
}

- (void)multiplyByMatrix:(L2DMatrix44Bridge *)matrix {
    Csm::CubismMatrix44::Multiply(matrix.getArray, _viewMatrix->GetArray(), _viewMatrix->GetArray());
}
@end
