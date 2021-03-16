//
//  L2DOpenGLRender.h
//  iOSLive2DDemo
//
//  Created by VanJay on 2021/3/14.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "L2DMatrix44Bridge.h"

@class L2DOpenGLRender;
@class L2DUserModel;
@class L2DMatrix44Bridge;

NS_ASSUME_NONNULL_BEGIN

@protocol OpenGLRenderDelegate <NSObject>
@required

/// 用于外部接收刷新事件
/// @param renderer 渲染器
/// @param duration 时长
- (void)rendererUpdateWithRender:(L2DOpenGLRender *)renderer duration:(NSTimeInterval)duration;
@end

@interface L2DOpenGLRender : NSObject

@property (strong, nonatomic) GLKBaseEffect *baseEffect;
/// rect
@property (nonatomic, assign) CGRect renderRect;

// 默认 1.0
@property (nonatomic, assign) CGFloat scale;
/// テクスチャID
@property (nonatomic, readonly) GLuint textureId;
/// 前景色
@property (nonatomic, strong) UIColor *spriteColor;

@property (nonatomic, weak) id<OpenGLRenderDelegate> delegate;
@property (nonatomic, strong) L2DUserModel *model;
/// 外部设置的桥接对象
@property (nonatomic, strong) L2DMatrix44Bridge *bridgeOutSet;

/// 默认渲染人物高度与画布高度比例
- (float)defaultRenderScale;
@end

@interface L2DOpenGLRender (Renderer)

- (void)startWithView:(GLKView *)view;

- (void)update:(NSTimeInterval)time;

/**
 * @brief 描画する
 *
 * @param[in]     vertexBufferID    フラグメントシェーダID
 * @param[in]     fragmentBufferID  バーテックスシェーダID
 */
- (void)render:(GLuint)vertexBufferID fragmentBufferID:(GLuint)fragmentBufferID;

/**
 * @brief 描画する
 *
 * @param[in]     vertexBufferID    フラグメントシェーダID
 * @param[in]     fragmentBufferID  バーテックスシェーダID
 */
- (void)renderImmidiate:(GLuint)vertexBufferID fragmentBufferID:(GLuint)fragmentBufferID textureId:(GLuint)textureId uvArray:(float *)uvArray;

/**
 * @brief コンストラクタ
 *
 * @param[in]       pointX    x座標
 * @param[in]       pointY    y座標
 */
- (bool)isHit:(float)pointX PointY:(float)pointY;
@end

NS_ASSUME_NONNULL_END
