import MetalKit

public class MetalView: MTKView {
    
    let renderer: MetalRenderer = MetalRenderer()
    
    public init(frame frameRect: CGRect) {
        super.init(frame: frameRect, device: renderer.device)
    }

    required public init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override public func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        
        guard let currentDrawable = self.currentDrawable else { return }
        
        renderer.drawInView(currentDrawable)
    }
}