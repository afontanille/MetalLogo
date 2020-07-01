//
//  GameViewController.swift
//  MetalLogo-tvOS
//

//  Copyright (c) 2016 Antonin Fontanille. All rights reserved.
//

import UIKit
import Metal
import MetalKit


class GameViewController:UIViewController, MTKViewDelegate {
    
    private let renderer = MetalRenderer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup view properties
        let view = self.view as! MTKView
        view.device = renderer.device
        view.delegate = self
    }
    
    func draw(in view: MTKView) {
        guard let viewDrawable = view.currentDrawable else { return }
        
        self.renderer.drawInView(drawable: viewDrawable)
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
}
