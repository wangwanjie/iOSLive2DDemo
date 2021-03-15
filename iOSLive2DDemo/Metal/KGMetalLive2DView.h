//
//  KGMetalLive2DView.h
//  iOSLive2DDemo
//
//  Created by VanJay on 2020/12/19.
//

#import "L2DMetalRender.h"
#import <UIKit/UIKit.h>
#import "L2DModelActionProtocol.h"
#import "L2DViewRenderer.h"

NS_ASSUME_NONNULL_BEGIN

@interface KGMetalLive2DView : UIView <L2DModelActionProtocol, L2DViewRenderer>
/// 代理
@property (nonatomic, weak) id<MetalRenderDelegate> delegate;
/// 渲染
@property (nonatomic, strong, readonly) L2DMetalRender *renderer;

/// 已经创建了 transformBuffer，内部默认会将模型缩放到 KGMetalLive2DView 高度
/// 如果外部重写了该属性，需要自行处理缩放
/// setScale: setOrigin: 需要在此回调后设置才生效
@property (nonatomic, copy) void (^didCreatedTransformBuffer)(void);
@end

NS_ASSUME_NONNULL_END
