//
//  ViewController.swift
//  MetalLogo view controller
//
//  Created by Antonin Fontanille on 05/03/2016.
//  Copyright © 2016 Antonin Fontanille. All rights reserved.
//

import MetalKit

class ViewController: NSViewController {

    private var metalView: MTKView { get { return self.view as! MTKView } }
    
    private let renderer = MetalRenderer()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.metalView.device = MTLCreateSystemDefaultDevice()
        self.metalView.delegate = self.renderer
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

