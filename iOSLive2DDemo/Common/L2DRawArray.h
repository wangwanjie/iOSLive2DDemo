//
//  L2DRawArray.h
//  iOSLive2DDemo
//
//  Created by VanJay on 2020/12/19.
//

#import <Foundation/Foundation.h>

/// A float c array wrapper for fast calculations.
@interface RawFloatArray : NSObject

/// C array. Unsafe pointer in swift.
@property (nonatomic, assign, readonly) const float *floats;

/// Array length. In number of floats.
@property (nonatomic, assign, readonly) int count;

/// Init with C array and lengh in number of floats.
- (instancetype)initWithCArray:(const float *)floats count:(int)count;

- (NSArray<NSNumber *> *)floatArray;

/// Index access.
- (float)objectAtIndexedSubscript:(NSUInteger)index;

@end

@interface RawIntArray : NSObject

/// C array. Unsafe pointer in swift.
@property (nonatomic, assign, readonly) const int *ints;

/// Array length. In number of ints.
@property (nonatomic, assign, readonly) int count;

/// Init with C array and lengh in number of ints.
- (instancetype)initWithCArray:(const int *)ints count:(int)count;

/// Index access.
- (int)objectAtIndexedSubscript:(NSUInteger)index;

- (NSArray<NSNumber *> *)intArray;

@end

@interface RawUShortArray : NSObject

/// C array. Unsafe pointer in swift.
@property (nonatomic, assign, readonly) const unsigned short *ushorts;

/// Array length. In number of ushorts.
@property (nonatomic, assign, readonly) int count;

/// Init with C array and lengh in number of ushorts.
- (instancetype)initWithCArray:(const unsigned short *)ushorts count:(int)count;

- (NSArray<NSNumber *> *)ushortArray;

/// Index access.
- (unsigned short)objectAtIndexedSubscript:(NSUInteger)index;

@end
