//
//  ViewController.swift
//  MetalLogo view controller
//
//  Created by Antonin Fontanille on 05/03/2016.
//  Copyright © 2016 Antonin Fontanille. All rights reserved.
//

import MetalKit

class ViewController: NSViewController, MTKViewDelegate {

    private var metalView: MTKView { get { return self.view as! MTKView } }
    
    private let renderer = MetalRenderer()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.metalView.device = renderer.device
        self.metalView.delegate = self
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func draw(in view: MTKView) {
        guard let viewDrawable = view.currentDrawable else { return }
        
        self.renderer.drawInView(drawable: viewDrawable)
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
}

