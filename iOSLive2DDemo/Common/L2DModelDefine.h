//
//  L2DModelDefine.h
//  ShanBao
//
//  Created by VanJay on 2021/2/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(int, L2DBlendMode) {
    /// 普通混合模式
    L2DBlendModeNormal = 0,
    /// 相加混合模式
    L2DBlendModeAdditive = 1,
    /// 相乘混合模式
    L2DBlendModeMultiplicative = 2,
};

/// 运动优先级
typedef NS_ENUM(int, L2DPriority) {
    L2DPriorityNone = 0,
    L2DPriorityIdle = 1,
    L2DPriorityNormal = 2,
    L2DPriorityForce = 3
};

typedef NS_ENUM(NSUInteger, KGLive2DViewStatus) {
    KGLive2DViewStatusWaiting = 0,      ///< 执行待机动作
    KGLive2DViewStatusSinging = 1,      ///< 唱歌
    KGLive2DViewStatusPaused = 2,       ///< 暂停
    KGLive2DViewStatusResetWaiting = 3  ///< 执行重置后待机动作
};

typedef NSString *SBLive2DActionBlendMode NS_STRING_ENUM;

FOUNDATION_EXPORT SBLive2DActionBlendMode const SBLive2DActionBlendModeNormal;
FOUNDATION_EXPORT SBLive2DActionBlendMode const SBLive2DActionBlendModeAdditive;
FOUNDATION_EXPORT SBLive2DActionBlendMode const SBLive2DActionBlendModeMultiplicative;

NS_ASSUME_NONNULL_END
