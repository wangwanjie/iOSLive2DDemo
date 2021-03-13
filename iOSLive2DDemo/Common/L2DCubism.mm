//
//  L2DCubism.mm
//  ShanBao
//
//  Created by VanJay on 2020/12/19.
//

#import <Foundation/Foundation.h>
#import "CubismFramework.hpp"
#import "L2DCubism.h"

using namespace Csm;

/// Cubism allocator.
class Allocator : public ICubismAllocator {
    void *Allocate(const csmSizeType size) {
        return malloc(size);
    }

    void Deallocate(void *memory) {
        free(memory);
    }

    void *AllocateAligned(const csmSizeType size, const csmUint32 alignment) {
        size_t offset, shift, alignedAddress;
        void *allocation;
        void **preamble;
        offset = alignment - 1 + sizeof(void *);
        allocation = Allocate(size + static_cast<csmUint32>(offset));
        alignedAddress = reinterpret_cast<size_t>(allocation) + sizeof(void *);
        shift = alignedAddress % alignment;
        if (shift) {
            alignedAddress += (alignment - shift);
        }
        preamble = reinterpret_cast<void **>(alignedAddress);
        preamble[-1] = allocation;
        return reinterpret_cast<void *>(alignedAddress);
    }

    void DeallocateAligned(void *alignedMemory) {
        void **preamble;
        preamble = static_cast<void **>(alignedMemory);
        Deallocate(preamble[-1]);
    }
};

static Allocator allocator;
@implementation L2DCubism
+ (void)initializeLive2D {
    CubismFramework::StartUp(&allocator, NULL);
    CubismFramework::Initialize();
}

+ (void)dispose {
    CubismFramework::Dispose();
}

@end
