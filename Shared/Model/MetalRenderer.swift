//
//  MetalRenderer.swift
//  MetalLogo renderer
//
//  Created by Antonin Fontanille on 21/02/2016.
//  Copyright © 2016 Antonin Fontanille. All rights reserved.
//

import MetalKit

enum MetalRendererError: ErrorType {
    case LibraryNotLoaded
    case BufferError
}

class MetalRenderer : NSObject {
    
    internal let device = MTLCreateSystemDefaultDevice()
    
    private let commandQueue: MTLCommandQueue?
    
    private let vertexBuffer: MTLBuffer?
    
    private let indexBuffer: MTLBuffer?
    
    private var uniformBuffer: MTLBuffer?
    
    private var pipelineState: MTLRenderPipelineState?
    
    private let drawingObject: MetalLogo = MetalLogo()
    
    private var cameraObject = Camera()
    
    override init() {
        
        guard let device = self.device else { fatalError() }
        
        self.commandQueue = device.newCommandQueue()
        
        self.vertexBuffer = device.newBufferWithBytes(self.drawingObject.vertexData, length: sizeof(Vertex)*self.drawingObject.vertexData.count, options: MTLResourceOptions.CPUCacheModeDefaultCache)
        
        let indices = self.drawingObject.indexData
        
        self.indexBuffer = device.newBufferWithBytes(indices, length: sizeof(IndexType)*indices.count, options: MTLResourceOptions.CPUCacheModeDefaultCache)
        
        self.uniformBuffer = device.newBufferWithLength(sizeof(matrix_float4x4), options: MTLResourceOptions.CPUCacheModeDefaultCache)
        
        super.init()
        
        do {
            try self.makePipeline()
        } catch {
            fatalError()
        }
    }
    
    func makePipeline() throws {
        
        guard let library = self.device?.newDefaultLibrary() else {
            throw MetalRendererError.LibraryNotLoaded
        }
        
        // Get our shaders from the library
        let vertexFunc = library.newFunctionWithName("vertex_project")
        let fragmentFunc = library.newFunctionWithName("fragment_flatcolor")
        
        // Set our pipeline up
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunc
        pipelineDescriptor.fragmentFunction = fragmentFunc
        pipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormat.BGRA8Unorm
        
        // Create our render pipeline state
        try self.pipelineState = self.device?.newRenderPipelineStateWithDescriptor(pipelineDescriptor)
    }
    
    func updateUniformsForView(layer: CAMetalLayer) throws {
        guard let uniformBuffer = self.uniformBuffer else {
            throw MetalRendererError.BufferError
        }
        
        let drawableSize = layer.drawableSize
        
        self.cameraObject.aspect = Float(drawableSize.width / drawableSize.height)
        
        var modelViewProjectionMatrix = self.cameraObject.modelViewProjectionMatrix
        
        memcpy(uniformBuffer.contents(), &modelViewProjectionMatrix, sizeof(matrix_float4x4))
    }
    
    func drawInView(drawable: CAMetalDrawable) {
        
        guard let commandQueue = self.commandQueue, pipelineState = self.pipelineState else { return }
        
        do {
            try updateUniformsForView(drawable.layer)
        } catch {
            fatalError()
        }
        
        let commandBuffer = commandQueue.commandBuffer()
        
        let passDescriptor = MTLRenderPassDescriptor()
        
        passDescriptor.colorAttachments[0].texture = drawable.texture
        passDescriptor.colorAttachments[0].loadAction = MTLLoadAction.Clear
        passDescriptor.colorAttachments[0].storeAction = MTLStoreAction.Store
        passDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.55, 0.55, 0.55, 1)
        
        let commandEncoder = commandBuffer.renderCommandEncoderWithDescriptor(passDescriptor)
        commandEncoder.setRenderPipelineState(pipelineState)
        commandEncoder.setVertexBuffer(self.vertexBuffer, offset: 0, atIndex: 0)
        commandEncoder.setVertexBuffer(self.uniformBuffer, offset: 0, atIndex: 1)
        
        if let indexBuffer = self.indexBuffer {
            commandEncoder.drawIndexedPrimitives(MTLPrimitiveType.Triangle, indexCount: indexBuffer.length / sizeof(IndexType), indexType: MTLIndexType.UInt16, indexBuffer: indexBuffer, indexBufferOffset: 0)
        }
        
        commandEncoder.endEncoding()
        
        commandBuffer.presentDrawable(drawable)
        commandBuffer.commit()
        
    }
}