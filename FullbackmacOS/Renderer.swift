//
//  Renderer.swift
//  FullbackmacOS
//
//  Created by Muiz on 18/06/22.
//

import Foundation
import MetalKit

final class Renderer: NSObject {
    private var commandQueue: MTLCommandQueue!
    
    init(device: MTLDevice) {
        super.init()
        commandQueue = device.makeCommandQueue()
    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        let commandBuffer = commandQueue.makeCommandBuffer()!
        let encoder = commandBuffer.makeRenderCommandEncoder(
            descriptor: view.currentRenderPassDescriptor!)!
        
        encoder.endEncoding()
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
    }
}
