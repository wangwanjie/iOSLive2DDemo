//
//  L2DUserModel.h
//  iOSLive2DDemo
//
//  Created by VanJay on 2020/12/19.
//

#import "RawArray.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "L2DModelDefine.h"
#import "SBProductioEmotionExpression.h"

/// Live2D 模型
@interface L2DUserModel : NSObject

- (instancetype)initWithJsonDir:(NSString *)dirName mocJsonName:(NSString *)mocJsonName;

/// 执行表情
- (void)performExpression:(SBProductioEmotionExpression *)expression;

/// 执行 id 动作
- (void)setModelParameterNamed:(NSString *)name value:(float)value;

/// 执行表情
- (void)performExpressionWithExpressionID:(NSString *)expressionID;

/// 执行动作
/// @param groupName 动作组名
/// @param index 动作 id
/// @param priority 优先级
- (void)performMotion:(NSString *)groupName index:(NSUInteger)index priority:(L2DPriority)priority;

/// 随机显示表情
- (void)performRandomExpression;

/// 执行 id 动作
/// @param name 动作 id
/// @param blendMode 渲染模式
/// @param value 值
- (void)setModelParameterNamed:(NSString *)name blendMode:(L2DBlendMode)blendMode value:(float)value;

/// 获取某个动作 value
- (float)getValueForModelParameterNamed:(NSString *)name;

- (void)setPartsOpacityNamed:(NSString *)name opacity:(float)opacity;

- (float)getPartsOpacityNamed:(NSString *)name;

/// 画布大小
- (CGSize)modelSize;

// Drawables.
- (int)drawableCount;
- (RawIntArray *)renderOrders;
- (bool)isRenderOrderDidChangedForDrawable:(int)index;

// Vertices.
- (RawFloatArray *)vertexPositionsForDrawable:(int)index;
- (RawUShortArray *)vertexIndicesForDrawable:(int)index;
- (bool)isVertexPositionDidChangedForDrawable:(int)index;

// Textures.
- (NSArray *)textureURLs;
- (int)textureIndexForDrawable:(int)index;
- (RawFloatArray *)vertexTextureCoordinateForDrawable:(int)index;

// Masks.
- (RawIntArray *)masksForDrawable:(int)index;

// Draw modes.
- (bool)cullingModeForDrawable:(int)index;
- (L2DBlendMode)blendingModeForDrawable:(int)index;

// Opacity.
- (float)opacityForDrawable:(int)index;
- (bool)isOpacityDidChangedForDrawable:(int)index;

// Visibility.
- (bool)visibilityForDrawable:(int)index;
- (bool)isVisibilityDidChangedForDrawable:(int)index;

- (void)update;

- (void)updatePhysics:(NSTimeInterval)dt;

@end
