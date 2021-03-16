//
//  L2DUserModel.h
//  iOSLive2DDemo
//
//  Created by VanJay on 2020/12/19.
//

#import "L2DRawArray.h"
#import <UIKit/UIKit.h>
#import "SBProductioEmotionExpression.h"
#import "L2DModelActionProtocol.h"

@class L2DTextureManager;
@class L2DMatrix44Bridge;

/// Live2D 模型
@interface L2DUserModel : NSObject <L2DModelActionProtocol>

- (instancetype)initWithJsonDir:(NSString *)dirName mocJsonName:(NSString *)mocJsonName;

/// 如果使用 OpenGLES 渲染需要
- (void)createRenderer;

/// 画布大小
- (CGSize)modelSize;

// Drawables.
- (int)drawableCount;
- (RawIntArray *)renderOrders;
- (bool)isRenderOrderDidChangedForDrawable:(int)index;

// Vertices.
- (RawFloatArray *)vertexPositionsForDrawable:(int)index;
- (RawUShortArray *)vertexIndicesForDrawable:(int)index;
- (bool)isVertexPositionDidChangedForDrawable:(int)index;

// Textures.
/// 如果使用 OpenGLES 渲染需要
- (void)setupTexturesWithTextureManager:(L2DTextureManager *)textureManager;
- (NSArray<NSURL *> *)textureURLs;
- (int)textureIndexForDrawable:(int)index;
- (RawFloatArray *)vertexTextureCoordinateForDrawable:(int)index;

// Masks.
- (RawIntArray *)masksForDrawable:(int)index;

// Draw modes.
- (bool)cullingModeForDrawable:(int)index;
- (L2DBlendMode)blendingModeForDrawable:(int)index;

// Opacity.
- (float)opacityForDrawable:(int)index;
- (bool)isOpacityDidChangedForDrawable:(int)index;

// Visibility.
- (bool)visibilityForDrawable:(int)index;
- (bool)isVisibilityDidChangedForDrawable:(int)index;

- (void)update;

- (void)updateWithDeltaTime:(NSTimeInterval)dt;

/// 如果使用 OpenGLES 渲染需要
- (void)drawModel;
- (void)drawModelWithBridge:(L2DMatrix44Bridge *)bridge;

/**
 * @brief   画面をドラッグしたときの処理
 *
 * @param[in]   x   画面のX座標
 * @param[in]   y   画面のY座標
 */
- (void)onDrag:(float)x floatY:(float)y;

/**
 * @brief   画面をタップしたときの処理
 *
 * @param[in]   x   画面のX座標
 * @param[in]   y   画面のY座標
 */
- (void)onTap:(float)x floatY:(float)y;

/**
 * @brief    当たり判定テスト。<br>
 *            指定IDの頂点リストから矩形を計算し、座標が矩形範囲内か判定する。
 *
 * @param[in]   hitAreaName     当たり判定をテストする対象のID
 * @param[in]   x               判定を行うX座標
 * @param[in]   y               判定を行うY座標
 */
- (BOOL)hitTest:(const char *)hitAreaName x:(float)x y:(float)y;

@end
