/**
 * Copyright(c) Live2D Inc. All rights reserved.
 *
 * Use of this source code is governed by the Live2D Open Software license
 * that can be found at https://www.live2d.com/eula/live2d-open-software-license-agreement_en.html.
 */

#import <Foundation/Foundation.h>
#import "L2DAppDefine.h"

namespace L2DAppDefine {

    using namespace Csm;

    // 画面
    const csmFloat32 ViewMaxScale = 2.0f;
    const csmFloat32 ViewMinScale = 0.8f;

    const csmFloat32 ViewLogicalLeft = -1.0f;
    const csmFloat32 ViewLogicalRight = 1.0f;

    const csmFloat32 ViewLogicalMaxLeft = -2.0f;
    const csmFloat32 ViewLogicalMaxRight = 2.0f;
    const csmFloat32 ViewLogicalMaxBottom = -2.0f;
    const csmFloat32 ViewLogicalMaxTop = 2.0f;

    // 模型定义------------------------------------------
    // 放置模型的目录名称数组
    // 将目录名称与model3.json的名称匹配
    const csmChar* ModelDir[] = {
        "Shanbao",
        "Haru",
        "Hiyori",
        "Mark",
        "Natori",
        "Rice",
        "hiyori_pro"
    };
    const csmInt32 ModelDirSize = sizeof(ModelDir) / sizeof(const csmChar*);

    // 与外部定义文件（json）结合
    const csmChar* MotionGroupIdle = "Idle"; // 待机
    const csmChar* MotionGroupTapBody = "TapBody"; // 当您轻拍身体

    // 与外部定义文件（json）结合
    const csmChar* HitAreaNameHead = "Head";
    const csmChar* HitAreaNameBody = "Body";

    // 运动优先级常数
    const csmInt32 PriorityNone = 0;
    const csmInt32 PriorityIdle = 1;
    const csmInt32 PriorityNormal = 2;
    const csmInt32 PriorityForce = 3;

    // 调试日志显示选项
    const csmBool DebugLogEnable = true;
    const csmBool DebugTouchLogEnable = false;

    // 框架的日志级别设置输出
    const CubismFramework::Option::LogLevel CubismLoggingLevel = CubismFramework::Option::LogLevel_Verbose;
}
