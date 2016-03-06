//
//  Shader.metal
//  MetalKitExampleApp
//
//  Created by Antonin Fontanille on 10/01/2016.
//  Copyright © 2016 Antonin Fontanille. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


struct Vertex
{
    float4 position [[position]];
    float4 color;
};

struct Uniforms
{
    float4x4 modelViewProjectionMatrix;
};

vertex Vertex vertex_project(device Vertex *vertices [[buffer(0)]],
                             constant Uniforms *uniforms [[buffer(1)]],
                             uint vertexId [[vertex_id]])
{
    Vertex vertexOut;
    vertexOut.position = uniforms->modelViewProjectionMatrix * vertices[vertexId].position;
    vertexOut.color = vertices[vertexId].color;
    
    return vertexOut;
}

fragment half4 fragment_flatcolor(Vertex inVertex [[stage_in]])
{
    return half4(inVertex.color);
}