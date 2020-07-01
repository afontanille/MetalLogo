//
//  MetalRenderer.swift
//  MetalLogo renderer
//
//  Created by Antonin Fontanille on 21/02/2016.
//  Copyright © 2016 Antonin Fontanille. All rights reserved.
//

import MetalKit

enum MetalRendererError: Error {
    case LibraryNotLoaded
    case BufferError
}

public class MetalRenderer : NSObject {
    
    internal let device = MTLCreateSystemDefaultDevice()
    
    private let commandQueue: MTLCommandQueue?
    
    private let vertexBuffer: MTLBuffer?
    
    private let indexBuffer: MTLBuffer?
    
    private var uniformBuffer: MTLBuffer?
    
    private var pipelineState: MTLRenderPipelineState?
    
    private let drawingObject: MetalLogo = MetalLogo()
    
    private var cameraObject = Camera()
    
    public override init() {
        
        guard let device = self.device else {
            print("Device error")
            fatalError()
        }
        
        self.commandQueue = device.makeCommandQueue()
        
        self.vertexBuffer = device.makeBuffer(bytes: self.drawingObject.vertexData, length: MemoryLayout<Vertex>.size * self.drawingObject.vertexData.count, options: [])
        
        let indices = self.drawingObject.indexData
        
        self.indexBuffer = device.makeBuffer(bytes: indices, length: MemoryLayout<IndexType>.size * indices.count, options: [])
        
        self.uniformBuffer = device.makeBuffer(length: MemoryLayout<matrix_float4x4>.size, options: [])
        
        super.init()
        
        do {
            try self.makePipeline()
        } catch {
            print("Pipeline error")
            fatalError()
        }
    }
    
    func makePipeline() throws {
        
        // Get our shaders from the library
        let vertexFunc = try getShaderWithFunction(funcName: "vertex_project")
        let fragmentFunc = try getShaderWithFunction(funcName: "fragment_flatcolor")
        
        // Set our pipeline up
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunc
        pipelineDescriptor.fragmentFunction = fragmentFunc
        pipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormat.bgra8Unorm
        
        // Create our render pipeline state
        try self.pipelineState = self.device?.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
    
    func getShaderWithFunction(funcName: String) throws -> MTLFunction? {
        let path = Bundle.main.path(forResource: "logo", ofType: "metal")
        let input: String?
        let library: MTLLibrary
        
        do {
            input = try String(contentsOfFile: path!, encoding: String.Encoding.utf8)
            library = try device!.makeLibrary(source: input!, options: nil)
            
            return library.makeFunction(name: funcName)
        } catch {
            Swift.print(error)
            throw MetalRendererError.LibraryNotLoaded
        }
    }
    
    func updateUniformsForView(layer: CAMetalLayer) throws {
        guard let uniformBuffer = self.uniformBuffer else {
            throw MetalRendererError.BufferError
        }
        
        let drawableSize = layer.drawableSize
        
        self.cameraObject.aspect = Float(drawableSize.width / drawableSize.height)
        
        var modelViewProjectionMatrix = self.cameraObject.modelViewProjectionMatrix
        
        memcpy(uniformBuffer.contents(), &modelViewProjectionMatrix, MemoryLayout<matrix_float4x4>.size)
    }
    
    func drawInView(drawable: CAMetalDrawable) {
        
        guard let commandQueue = self.commandQueue, let pipelineState = self.pipelineState else { return }
        
        do {
            try updateUniformsForView(layer: drawable.layer)
        } catch {
            fatalError()
        }
        
        let commandBuffer = commandQueue.makeCommandBuffer()
        
        let passDescriptor = MTLRenderPassDescriptor()
        
        passDescriptor.colorAttachments[0].texture = drawable.texture
        passDescriptor.colorAttachments[0].loadAction = MTLLoadAction.clear
        passDescriptor.colorAttachments[0].storeAction = MTLStoreAction.dontCare
        passDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.55, 0.55, 0.55, 1)
        
        guard let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: passDescriptor) else {
            return
        }
        
        commandEncoder.setRenderPipelineState(pipelineState)
        commandEncoder.setVertexBuffer(self.vertexBuffer, offset: 0, index: 0)
        commandEncoder.setVertexBuffer(self.uniformBuffer, offset: 0, index: 1)
        
        if let indexBuffer = self.indexBuffer {
            commandEncoder.drawIndexedPrimitives(type: MTLPrimitiveType.triangle, indexCount: indexBuffer.length / MemoryLayout<IndexType>.size, indexType: MTLIndexType.uint16, indexBuffer: indexBuffer, indexBufferOffset: 0)
        }
        
        commandEncoder.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
