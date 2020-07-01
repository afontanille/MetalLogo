//
//  CameraData.swift
//  MetalLogo Camera model
//
//  Created by Antonin Fontanille on 11/01/2016.
//  Copyright © 2016 Antonin Fontanille. All rights reserved.
//

import simd

extension Float {
    func rad() -> Float {
        return self * .pi / 180.0
    }
}

public struct Camera {
    
    var rotationX: Float = 0.0
    var rotationY: Float = 0.0
    var distance: Float = -2
    
    var aspect: Float = 16/9
    var fov: Float = Float((2.0 * .pi) / 5.0)
    var near: Float = 1.0
    var far: Float = 100
    
    var modelViewProjectionMatrix: matrix_float4x4 {
        get {
            let xAxis = vector_float3(1, 0, 0)
            let yAxis = vector_float3(0, 1, 0)
            let xRot = matrix_float4x4_rotation(axis: xAxis, angle: self.rotationX.rad())
            let yRot = matrix_float4x4_rotation(axis: yAxis, angle: self.rotationY.rad())
            
            let modelMatrix = matrix_multiply(xRot, yRot)
            let viewMatrix = matrix_float4x4_translation(vector_float3(0, 0, distance))
            let projectionMatrix = matrix_float4x4_perspective(aspect: aspect, fovy: fov, near: near, far: far)
            
            return matrix_multiply(projectionMatrix ,matrix_multiply(viewMatrix, modelMatrix))
        }
    }
}
