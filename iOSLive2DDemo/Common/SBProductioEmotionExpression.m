//
//  SBProductioEmotionExpression.m
//  iOSLive2DDemo
//
//  Created by VanJay on 2021/3/13.
//

#import "SBProductioEmotionExpression.h"

@implementation SBProductioEmotionExpressionActionParameter

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
        @"paramId": @"Id",
        @"value": @"Value",
        @"blendDesc": @"Blend"
    };
}

- (void)setBlendDesc:(SBLive2DActionBlendMode)blendDesc {
    _blendDesc = blendDesc;

    if ([blendDesc isEqualToString:SBLive2DActionBlendModeNormal]) {
        _blendType = L2DBlendModeNormal;
    } else if ([blendDesc isEqualToString:SBLive2DActionBlendModeAdditive]) {
        _blendType = L2DBlendModeAdditive;
    } else if ([blendDesc isEqualToString:SBLive2DActionBlendModeMultiplicative]) {
        _blendType = L2DBlendModeMultiplicative;
    }
}
@end

@implementation SBProductioEmotionExpressionAction

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
        @"type": @"Type",
        @"parameters": @"Parameters"
    };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
        @"parameters": SBProductioEmotionExpressionActionParameter.class,
    };
}

@end

@implementation SBProductioEmotionExpression

@end
