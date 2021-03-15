//
//  L2DRawArray.m
//  iOSLive2DDemo
//
//  Created by VanJay on 2020/12/19.
//

#import "L2DRawArray.h"

// Float array.
@implementation RawFloatArray
- (instancetype)initWithCArray:(const float *)floats count:(int)count {
    if (self = [super init]) {
        _floats = floats;
        _count = count;
    }
    return self;
}

- (NSArray<NSNumber *> *)floatArray {
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < _count; ++i) {
        @autoreleasepool {
            [array addObject:[NSNumber numberWithFloat:_floats[i]]];
        }
    }
    return array;
}

- (float)objectAtIndexedSubscript:(NSUInteger)index {
    return _floats[index];
}
@end

// Int array.
@implementation RawIntArray
- (instancetype)initWithCArray:(const int *)ints count:(int)count {
    if (self = [super init]) {
        _ints = ints;
        _count = count;
    }
    return self;
}

- (NSArray<NSNumber *> *)intArray {
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < _count; ++i) {
        @autoreleasepool {
            [array addObject:[NSNumber numberWithFloat:_ints[i]]];
        }
    }
    return array;
}

- (int)objectAtIndexedSubscript:(NSUInteger)index {
    return _ints[index];
}
@end

// Unsigned short array.
@implementation RawUShortArray
- (instancetype)initWithCArray:(const unsigned short *)ushorts count:(int)count {
    if (self = [super init]) {
        _ushorts = ushorts;
        _count = count;
    }
    return self;
}

- (NSArray<NSNumber *> *)ushortArray {
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < _count; ++i) {
        @autoreleasepool {
            [array addObject:[NSNumber numberWithUnsignedShort:_ushorts[i]]];
        }
    }
    return array;
}

- (unsigned short)objectAtIndexedSubscript:(NSUInteger)index {
    return _ushorts[index];
}

@end
