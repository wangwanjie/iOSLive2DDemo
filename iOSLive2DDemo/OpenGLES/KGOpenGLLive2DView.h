//
//  KGOpenGLLive2DView.h
//  iOSLive2DDemo
//
//  Created by VanJay on 2021/3/14.
//

#import <UIKit/UIKit.h>
#import "L2DAppDefine.h"
#import "L2DModelActionProtocol.h"
#import "L2DViewRenderer.h"

NS_ASSUME_NONNULL_BEGIN

@interface KGOpenGLLive2DView : UIView <L2DModelActionProtocol, L2DViewRenderer>

@property (nonatomic, assign) SelectTarget renderTarget;
/// 前景色
@property (nonatomic, strong) UIColor *spriteColor;
@end

NS_ASSUME_NONNULL_END
