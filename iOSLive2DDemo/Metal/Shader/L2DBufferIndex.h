//
//  L2DBufferIndex
//  ShanBao
//
//  Created by VanJay on 2020/12/19.
//

#ifndef L2DBufferIndex_h
#define L2DBufferIndex_h

/// Shader buffer index.
typedef enum L2DBufferIndex {
    L2DBufferIndexTransform = 0,
    L2DBufferIndexPosition = 1,
    L2DBufferIndexUV = 2,
    L2DBufferIndexOpacity = 3
} L2DBufferIndex;

/// Shader attribute index.
typedef enum L2DAttributeIndex {
    L2DAttributeIndexPosition = 0,
    L2DAttributeIndexUV = 1,
    L2DAttributeIndexOpacity = 2
} L2DAttributeIndex;

/// Shader texture index.
typedef enum L2DTextureIndex {
    L2DTextureIndexUniform = 0,
    L2DTextureIndexMask = 1
} L2DTextureIndex;

#endif /* L2DBufferIndex_h */
