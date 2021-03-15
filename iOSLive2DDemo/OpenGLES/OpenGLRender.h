//
//  OpenGLRender.h
//  iOSLive2DDemo
//
//  Created by VanJay on 2021/3/14.
//

#import <Foundation/Foundation.h>
#import "L2DUserModel.h"
#import <GLKit/GLKit.h>

@class OpenGLRender;

NS_ASSUME_NONNULL_BEGIN

@protocol OpenGLRenderDelegate <NSObject>
@required

/// 用于外部接收刷新事件
/// @param renderer 渲染器
/// @param duration 时长
- (void)rendererUpdateWithRender:(OpenGLRender *)renderer duration:(NSTimeInterval)duration;
@end

@interface OpenGLRender : NSObject

@property (strong, nonatomic) GLKBaseEffect *baseEffect;
/// rect
@property (nonatomic, assign) CGRect renderRect;
@property (nonatomic, readonly, getter=GetTextureId) GLuint textureId;  // テクスチャID
/// 前景色
@property (nonatomic, assign) GLKVector4 spriteColor;

@property (nonatomic, weak) id<OpenGLRenderDelegate> delegate;
@property (nonatomic, strong) L2DUserModel *model;
@end

@interface OpenGLRender (Renderer)

- (void)startWithView:(GLKView *)view;

- (void)drawableSizeWillChange:(GLKView *)view size:(CGSize)size;

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
- (void)renderImmidiate:(GLuint)vertexBufferID fragmentBufferID:(GLuint)fragmentBufferID TextureId:(GLuint)textureId uvArray:(float *)uvArray;

/**
 * @brief コンストラクタ
 *
 * @param[in]       pointX    x座標
 * @param[in]       pointY    y座標
 */
- (bool)isHit:(float)pointX PointY:(float)pointY;
@end

NS_ASSUME_NONNULL_END