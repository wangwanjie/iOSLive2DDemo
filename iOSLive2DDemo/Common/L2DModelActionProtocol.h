//
//  L2DModelActionProtocol.h
//  iOSLive2DDemo
//
//  Created by VanJay on 2021/3/15.
//

#ifndef L2DModelActionProtocol_h
#define L2DModelActionProtocol_h

#import <UIKit/UIKit.h>
#import "L2DModelDefine.h"

@class SBProductioEmotionExpression;

@protocol L2DModelActionProtocol <NSObject>

@required
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

@end

#endif /* L2DModelActionProtocol_h */
