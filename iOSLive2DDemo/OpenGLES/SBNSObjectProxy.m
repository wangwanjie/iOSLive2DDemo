//
//  SBNSObjectProxy.m
//  iOSLive2DDemo
//
//  Created by VanJay on 2021/3/15.
//

#import "SBNSObjectProxy.h"

@interface SBNSObjectProxy ()
/// 对象
@property (nonatomic, weak) NSObject *obj;
@end

@implementation SBNSObjectProxy
+ (instancetype)proxyWithObj:(NSObject *)obj {
    SBNSObjectProxy *proxy = [SBNSObjectProxy alloc];
    proxy.obj = obj;
    return proxy;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *sig = nil;
    sig = [self.obj methodSignatureForSelector:aSelector];
    return sig;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    [anInvocation invokeWithTarget:self.obj];
}
@end
