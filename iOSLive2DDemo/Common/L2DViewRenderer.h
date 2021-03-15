//
//  L2DViewRenderer.h
//  iOSLive2DDemo
//
//  Created by VanJay on 2021/3/15.
//

#ifndef L2DViewRenderer_h
#define L2DViewRenderer_h

#import <UIKit/UIKit.h>

@protocol L2DViewRenderer <NSObject>

@required

/// 加载资源 json
/// @param dirName model3 文件夹路径
/// @param mocJsonName model3 名称
- (void)loadLive2DModelWithDir:(NSString *)dirName mocJsonName:(NSString *)mocJsonName;

- (void)setParameterWithDictionary:(NSDictionary<NSString *, NSNumber *> *)params;
- (void)setPartOpacityWithDictionary:(NSDictionary<NSString *, NSNumber *> *)parts;

@property (nonatomic, assign) NSInteger preferredFramesPerSecond;
@property (nonatomic, assign) BOOL paused;
- (CGSize)canvasSize;

@end

#endif /* L2DViewRenderer_h */
