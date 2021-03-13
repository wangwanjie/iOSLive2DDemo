//
//  UIColor+Live2D.h
//  iOSLive2DDemo
//
//  Created by VanJay on 2020/12/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef struct {
    CGFloat r;
    CGFloat g;
    CGFloat b;
    CGFloat a;
} RGBA;

@interface UIColor (Live2D)
///< rgba 值
@property (nonatomic, assign, readonly) RGBA rgba;
@end

NS_ASSUME_NONNULL_END
