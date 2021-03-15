//
//  SBNSObjectProxy.h
//  iOSLive2DDemo
//
//  Created by VanJay on 2021/3/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SBNSObjectProxy : NSProxy
+ (instancetype)proxyWithObj:(NSObject *)obj;
@end

NS_ASSUME_NONNULL_END
