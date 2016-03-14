//
//  MetalLogo.swift
//  MetalLogo model
//
//  Created by Antonin Fontanille on 20/02/2016.
//  Copyright © 2016 Antonin Fontanille. All rights reserved.
//

import simd

typealias IndexType = UInt16

public struct Vertex {
    var position: float4
    var color: float4
}

public struct MetalLogo {
    
    let vertexData: [Vertex] = [
        Vertex(position: float4(-0.62, -0.58,  0, 1), color: float4(0.757, 0.0,   0.294, 1)),
        Vertex(position: float4(-0.62,  0.74,  0, 1), color: float4(0.945, 0.086, 0.145, 1)),
        Vertex(position: float4( 0.0,   0.0,   0, 1), color: float4(0.729, 0.0,   0.310, 1)),
        Vertex(position: float4( 0.0,   0.52,  0, 1), color: float4(0.808, 0.0,   0.247, 1)),
        Vertex(position: float4( 1.01, -0.58,  0, 1), color: float4(0.322, 0.0,   0.533, 1)),
        
        Vertex(position: float4( 0.75, -0.58,  0, 1), color: float4(0.353, 0.0,   0.525, 1)),
        Vertex(position: float4( 0.19,  0.04,  0, 1), color: float4(0.725, 0.0,   0.325, 1)),
        Vertex(position: float4( 0.19, -0.57,  0, 1), color: float4(0.635, 0.0,   0.404, 1)),
        Vertex(position: float4(-0.42,  0.18,  0, 1), color: float4(0.886, 0.055, 0.184, 1)),
        Vertex(position: float4(-0.42, -0.58,  0, 1), color: float4(0.745, 0.0,   0.306, 1))
    ];
    
    let indexData: [IndexType] = [
        // Triangles
        0, 1, 9,
        1, 8, 9,
        1, 7, 8,
        1, 2, 7,
        7, 2, 3,
        3, 6, 7,
        6, 3, 5,
        3, 4, 5
    ];
}