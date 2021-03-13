//
//  KGlive2DView.h
//  ShanBao
//
//  Created by VanJay on 2020/12/19.
//

#import "MetalRender.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, KGLive2dViewStatus) {
    KGLive2dViewStatusWaiting = 0,      ///< 执行待机动作
    KGLive2dViewStatusSinging = 1,      ///< 唱歌
    KGLive2dViewStatusPaused = 2,       ///< 暂停
    KGLive2dViewStatusResetWaiting = 3  ///< 执行重置后待机动作
};

@interface KGlive2DView : UIView

/// 加载资源 json
/// @param path model3 文件路径
- (void)loadLive2DResourcesWithPath:(NSString *)path;
- (void)performExpression:(SBProductioEmotionExpression *)expression;
- (void)setParameterNamed:(NSString *)name value:(float)value;
- (void)setParameterNamed:(NSString *)name blendMode:(L2DBlendMode)blendMode value:(float)value;
- (float)valueForParameterNamed:(NSString *)name;
- (void)setParameterWithDictionary:(NSDictionary<NSString *, NSNumber *> *)params;

- (void)setPartOpacityNamed:(NSString *)name value:(float)value;
- (float)valueForPartOpacityNamed:(NSString *)name;
- (void)setPartOpacityWithDictionary:(NSDictionary<NSString *, NSNumber *> *)parts;

- (void)handleDealloc;

@property (nonatomic, assign) NSInteger preferredFramesPerSecond;
@property (nonatomic, assign) BOOL paused;
@property (nonatomic, assign, readonly) CGSize canvasSize;

/// 代理
@property (nonatomic, weak) id<MetalRenderDelegate> delegate;
/// 渲染
@property (nonatomic, strong, readonly) MetalRender *renderer;

/// 已经创建了 transformBuffer，内部默认会将模型缩放到 KGlive2DView 高度
/// 如果外部重写了该属性，需要自行处理缩放
/// setScale: setOrigin: 需要在此回调后设置才生效
@property (nonatomic, copy) void (^didCreatedTransformBuffer)(void);
@end

NS_ASSUME_NONNULL_END
