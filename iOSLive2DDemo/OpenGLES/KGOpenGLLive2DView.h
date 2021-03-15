//
//  KGOpenGLLive2DView.h
//  iOSLive2DDemo
//
//  Created by VanJay on 2021/3/14.
//

#import <UIKit/UIKit.h>
#import "L2DModelDefine.h"
#import "L2DModelActionProtocol.h"
#import "L2DViewRenderer.h"
#import "L2DOpenGLRender.h"

NS_ASSUME_NONNULL_BEGIN

@interface KGOpenGLLive2DView : UIView <L2DModelActionProtocol, L2DViewRenderer>
/// 代理
@property (nonatomic, weak) id<OpenGLRenderDelegate> delegate;
/// 前景色
@property (nonatomic, strong) UIColor *spriteColor;
@end

NS_ASSUME_NONNULL_END
