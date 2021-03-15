//
//  KGMetalLive2DView.h
//  iOSLive2DDemo
//
//  Created by VanJay on 2020/12/19.
//

#import "MetalRender.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KGMetalLive2DView : UIView

/// 加载资源 json
/// @param dirName model3 文件夹路径
/// @param mocJsonName model3 名称
- (void)loadLive2DModelWithDir:(NSString *)dirName mocJsonName:(NSString *)mocJsonName;
- (void)performExpression:(SBProductioEmotionExpression *)expression;
- (void)setParameterNamed:(NSString *)name value:(float)value;
- (void)setParameterNamed:(NSString *)name blendMode:(L2DBlendMode)blendMode value:(float)value;
- (float)valueForParameterNamed:(NSString *)name;
- (void)setParameterWithDictionary:(NSDictionary<NSString *, NSNumber *> *)params;

- (void)setPartOpacityNamed:(NSString *)name value:(float)value;
- (float)valueForPartOpacityNamed:(NSString *)name;
- (void)setPartOpacityWithDictionary:(NSDictionary<NSString *, NSNumber *> *)parts;

@property (nonatomic, assign) NSInteger preferredFramesPerSecond;
@property (nonatomic, assign) BOOL paused;
@property (nonatomic, assign, readonly) CGSize canvasSize;

/// 代理
@property (nonatomic, weak) id<MetalRenderDelegate> delegate;
/// 渲染
@property (nonatomic, strong, readonly) MetalRender *renderer;

/// 已经创建了 transformBuffer，内部默认会将模型缩放到 KGMetalLive2DView 高度
/// 如果外部重写了该属性，需要自行处理缩放
/// setScale: setOrigin: 需要在此回调后设置才生效
@property (nonatomic, copy) void (^didCreatedTransformBuffer)(void);
@end

NS_ASSUME_NONNULL_END
