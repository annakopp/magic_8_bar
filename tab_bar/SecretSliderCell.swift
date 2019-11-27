import Cocoa

class SecretSliderCell: NSSliderCell {
    
    override func drawBar(inside rect: NSRect, flipped: Bool) {
        let barRadius = CGFloat(0)
        let value = CGFloat((self.doubleValue - self.minValue) / (self.maxValue - self.minValue))
        let finalWidth = CGFloat(value * (self.controlView!.frame.size.width - 8))
        var leftRect = rect
        leftRect.size.width = finalWidth
        let bg = NSBezierPath(roundedRect: rect, xRadius: barRadius, yRadius: barRadius)
        NSColor.orange.setFill()
        NSColor.clear.setFill()
        bg.fill()
        let active = NSBezierPath(roundedRect: leftRect, xRadius: barRadius, yRadius: barRadius)
        NSColor.clear.setFill()
        active.fill()
    }
    
//    override func drawKnob(_ knobRect: NSRect) {
//        
//    }

}
