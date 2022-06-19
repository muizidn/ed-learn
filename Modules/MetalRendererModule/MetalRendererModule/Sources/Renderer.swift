//
//  Renderer.swift
//  FullbackmacOS
//
//  Created by Muiz on 18/06/22.
//

import Foundation
import MetalKit

public final class Renderer: NSObject {
    private var commandQueue: MTLCommandQueue!
    private let device: MTLDevice
    
    private var vertices: [Float] = [
        0, 1, 0,
        -1, -1, 0,
        1, -1, 0
    ]
    
    private var pipelineState: MTLRenderPipelineState!
    private var vertexBuffer: MTLBuffer!
    
    public init(device: MTLDevice) {
        self.device = device
        commandQueue = device.makeCommandQueue()
        super.init()
        buildModel()
        buildPipelineState()
    }
    
    private func buildModel() {
        vertexBuffer = device.makeBuffer(bytes: vertices,
                                         length: vertices.count * MemoryLayout<Float>.size,
                                         options: [])
    }
    
    private func buildPipelineState() {
        let library = try device.makeDefaultLibrary()!
        let vertexFunction = library.makeFunction(name: "vertex_shader")
        let fragmentFunction = library.makeFunction(name: "fragment_shader")
        
        let pipelineDescriptor =  MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            print("ERROR \(error.localizedDescription)")
        }
    }
}

extension Renderer: MTKViewDelegate {
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    public func draw(in view: MTKView) {
        let commandBuffer = commandQueue.makeCommandBuffer()!
        let encoder = commandBuffer.makeRenderCommandEncoder(
            descriptor: view.currentRenderPassDescriptor!)!
        
        encoder.setRenderPipelineState(pipelineState)
        encoder.setVertexBuffer(vertexBuffer,
                                offset: 0,
                                index: 0)
        encoder.drawPrimitives(type: .triangle,
                               vertexStart: 0,
                               vertexCount: vertices.count)
        
        encoder.endEncoding()
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
    }
}
