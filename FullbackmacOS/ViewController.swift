//
//  ViewController.swift
//  MetalTutorialMac
//
//  Created by Muiz on 18/06/22.
//

import Cocoa
import MetalKit
import MetalRendererModule

final class ViewController: NSViewController {

    private lazy var metalView = MTKView()
    private var renderer: Renderer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(metalView)
        metalView.frame = view.bounds
        metalView.autoresizingMask = [.width, .height]
        metalView.device = MTLCreateSystemDefaultDevice()
        renderer = Renderer(device: metalView.device!)
        metalView.delegate = renderer
        
        metalView.clearColor = MTLClearColor(red: 0, green: 1, blue: 0, alpha: 1)
    }
}
