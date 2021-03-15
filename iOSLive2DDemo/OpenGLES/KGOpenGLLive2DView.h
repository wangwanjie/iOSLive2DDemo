//
//  KGOpenGLLive2DView.h
//  iOSLive2DDemo
//
//  Created by VanJay on 2021/3/14.
//

#import <UIKit/UIKit.h>
#import "L2DAppDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface KGOpenGLLive2DView : UIView

/// 加载资源 json
/// @param dirName model3 文件夹路径
/// @param mocJsonName model3 名称
- (void)loadLive2DModelWithDir:(NSString *)dirName mocJsonName:(NSString *)mocJsonName;

@property (nonatomic) NSInteger preferredFramesPerSecond;
@property (nonatomic, assign) BOOL paused;
@property (nonatomic, assign, readonly) CGSize canvasSize;
@property (nonatomic, assign) SelectTarget renderTarget;
/// 前景色
@property (nonatomic, strong) UIColor *spriteColor;
@end

NS_ASSUME_NONNULL_END
