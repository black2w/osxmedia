//
//  ShaderTypes.h
//  PreviewWithMetal
//
//  Created by SXC on 2018/7/7.
//  Copyright © 2018年 sxc. All rights reserved.
//

#ifndef ShaderTypes_h
#define ShaderTypes_h

#include <simd/simd.h>

typedef struct {
    vector_float2 position;
    vector_float2 coordinate;
} PWMVertex;

typedef struct
{
    vector_float4 position;
    vector_float2 textureCoordinate;
} LYVertex;


typedef enum LYVertexInputIndex {
    LYVertexInputIndexVertices     = 0,
} LYVertexInputIndex;


typedef enum LYFragmentTextureIndex {
    LYFragmentTextureIndexTextureSource     = 0,
    LYFragmentTextureIndexTextureDest       = 1,
} LYFragmentTextureIndex;



#endif /* ShaderTypes_h */
