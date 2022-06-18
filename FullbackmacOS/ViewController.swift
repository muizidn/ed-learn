//
//  ViewController.swift
//  MetalTutorialMac
//
//  Created by Muiz on 18/06/22.
//

import Cocoa
import MetalKit

final class ViewController: NSViewController {

    private lazy var metalView = MTKView()
    
    private var device: MTLDevice!
    private var commandQueue: MTLCommandQueue!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(metalView)
        metalView.frame = view.bounds
        metalView.autoresizingMask = [.width, .height]
        metalView.delegate = self
        
        metalView.clearColor = MTLClearColor(red: 1, green: 0, blue: 0, alpha: 1)
        
        device = MTLCreateSystemDefaultDevice()
        commandQueue = device.makeCommandQueue()
    }
}


extension ViewController: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        view.device = device
        let commandBuffer = commandQueue.makeCommandBuffer()!
        let encoder = commandBuffer.makeRenderCommandEncoder(
            descriptor: metalView.currentRenderPassDescriptor!)!
        
        encoder.endEncoding()
        commandBuffer.present(metalView.currentDrawable!)
        commandBuffer.commit()
    }
}
