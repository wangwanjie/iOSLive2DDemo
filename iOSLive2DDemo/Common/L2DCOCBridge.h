//
//  L2DCOCBridge.h
//  iOSLive2DDemo
//
//  Created by VanJay on 2021/3/15.
//

#import <Foundation/Foundation.h>
#import <CubismFramework.hpp>
#import <Math/CubismMatrix44.hpp>

NS_ASSUME_NONNULL_BEGIN

/// 桥接文件，解决编译问题
@interface L2DCOCBridge : NSObject
/// モデル描画に用いるView行列
@property (nonatomic, assign) Csm::CubismMatrix44 *viewMatrix;
@end

NS_ASSUME_NONNULL_END
