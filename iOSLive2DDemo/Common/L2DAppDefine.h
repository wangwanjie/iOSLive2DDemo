/**
 * Copyright(c) Live2D Inc. All rights reserved.
 *
 * Use of this source code is governed by the Live2D Open Software license
 * that can be found at https://www.live2d.com/eula/live2d-open-software-license-agreement_en.html.
 */

#import <Foundation/Foundation.h>
#import <CubismFramework.hpp>

typedef NS_ENUM(NSUInteger, SelectTarget) {
    SelectTarget_None,              ///< デフォルトのフレームバッファにレンダリング
    SelectTarget_ModelFrameBuffer,  ///< L2DUserModelが各自持つフレームバッファにレンダリング
    SelectTarget_ViewFrameBuffer,   ///< L2DViewの持つフレームバッファにレンダリング
};

/**
 * @brief  Sample Appで使用する定数
 *
 */
namespace L2DAppDefine {

    using namespace Csm;

    extern const csmFloat32 ViewMaxScale;           ///< 最大缩放比例
    extern const csmFloat32 ViewMinScale;           ///< 最小比例因子

    extern const csmFloat32 ViewLogicalLeft;        ///< 逻辑视图坐标系中的最左值
    extern const csmFloat32 ViewLogicalRight;       ///< 逻辑视图坐标系中的最右边的值

    extern const csmFloat32 ViewLogicalMaxLeft;     ///< 逻辑视图坐标系左端的最大值
    extern const csmFloat32 ViewLogicalMaxRight;    ///< 逻辑视图坐标系右端的最大值
    extern const csmFloat32 ViewLogicalMaxBottom;   ///< 逻辑视图坐标系底部的最大值
    extern const csmFloat32 ViewLogicalMaxTop;      ///< 逻辑视图坐标系的最大上边缘

    // 模型定义------------------------------------------
    // 放置模型的目录名称数组
    // 将目录名称与model3.json的名称匹配
    extern const csmChar* ModelDir[];
    extern const csmInt32 ModelDirSize;

    // 与外部定义文件（json）结合
    extern const csmChar* MotionGroupIdle;          ///< 空转时要播放的动作列表
    extern const csmChar* MotionGroupTapBody;       ///< 点击身体时要播放的动作列表

    // 与外部定义文件（json）结合
    extern const csmChar* HitAreaNameHead;          ///< [Head]标签以进行碰撞检测
    extern const csmChar* HitAreaNameBody;          ///< [Body]标签以进行碰撞检测

    // 运动优先级常数
    extern const csmInt32 PriorityNone;             ///< 运动优先级常数：0
    extern const csmInt32 PriorityIdle;             ///< 动作优先级常量：1
    extern const csmInt32 PriorityNormal;           ///< 运动优先级常数：2
    extern const csmInt32 PriorityForce;            ///< 动作优先级常量：3

    // 调试日志显示选项
    extern const csmBool DebugLogEnable;            ///< 启用/禁用调试日志显示
    extern const csmBool DebugTouchLogEnable;       ///< 启用/禁用日志显示以调试触摸处理

    // 框架的日志级别设置输出
    extern const CubismFramework::Option::LogLevel CubismLoggingLevel;
}
