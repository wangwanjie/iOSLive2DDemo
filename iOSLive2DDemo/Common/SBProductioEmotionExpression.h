//
//  SBProductioEmotionExpression.h
//  iOSLive2DDemo
//
//  Created by VanJay on 2021/3/13.
//

#import <Foundation/Foundation.h>
#import "L2DModelDefine.h"
#import <YYModel/YYModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface SBProductioEmotionExpressionActionParameter : NSObject
/// 动作 id
@property (nonatomic, copy) NSString *paramId;
/// 动作值
@property (nonatomic, assign) double value;
/// 渲染模式
@property (nonatomic, assign) L2DBlendMode blendType;
/// 渲染模式字符串
@property (nonatomic, copy) SBLive2DActionBlendMode blendDesc;
@end

@interface SBProductioEmotionExpressionAction : NSObject
/// 类型
@property (nonatomic, copy) NSString *type;
/// 具体动作
@property (nonatomic, copy) NSArray<SBProductioEmotionExpressionActionParameter *> *parameters;
@end

@interface SBProductioEmotionExpression : NSObject
/// 描述
@property (nonatomic, copy) NSString *desc;
/// 淡出时间（单位：ms）
@property (nonatomic, assign) NSTimeInterval fadeTime;
/// 持续时长（单位：ms）
@property (nonatomic, assign) NSTimeInterval duration;
/// 起始时间（单位：ms）
@property (nonatomic, assign) NSTimeInterval startTime;
/// 动作
@property (nonatomic, strong) SBProductioEmotionExpressionAction *action;
/// 是否已经执行
@property (nonatomic, assign) BOOL hasPerformed;
@end

NS_ASSUME_NONNULL_END
