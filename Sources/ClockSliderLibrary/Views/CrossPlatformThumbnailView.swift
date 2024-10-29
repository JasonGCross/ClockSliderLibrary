//
//  CrossPlatformThumbnailView.swift
//  ClockSliderLibrary
//
//  Created by Jason Cross on 2024-10-29.
//

import Foundation
import CoreGraphics

public class CrossPlatformThumbnailView {
    var thumbnailImage : CGImage?
    var thumbnailColor: CGColor?
    var isHighlighted: Bool = false
    
    let ringWidth: CGFloat
    let radiusClockCenterToSliderTrackCenter: CGFloat
    let clockRadius: CGFloat
    let halfSliderTrackWidth: CGFloat
    internal let angleEquivalentToOnePixel: CGFloat = CGFloat(Double.pi / 360.0)
    public var drawableEndAngle: CGFloat = 0
    
    public init(_frame: CGRect,
         _ringWidth: CGFloat,
         _clockRadius: CGFloat,
         _thumbnailImage: CGImage? = nil,
         _thumbnailColor: CGColor? = nil) {
        
        ringWidth = _ringWidth
        halfSliderTrackWidth = (ringWidth / 2.0)
        clockRadius = _clockRadius
        radiusClockCenterToSliderTrackCenter = clockRadius - halfSliderTrackWidth
        thumbnailImage = _thumbnailImage
        thumbnailColor = _thumbnailColor
    }
    
    // MARK: - drawing
    public func draw(_ dirtyRect: CGRect, context: CGContext) {
        let rect = dirtyRect
        
        if let safeColor = self.thumbnailColor {
            context.saveGState()
            
            context.setFillColor(safeColor)
            context.beginPath()
            let center = CGPoint(x: rect.size.width / 2.0, y: rect.size.height / 2.0)
            
            context.addArc(center: center,
                            radius: halfSliderTrackWidth,
                            startAngle: drawableEndAngle - CGFloat((Double.pi / 2.0)),
                            endAngle: drawableEndAngle + CGFloat((Double.pi / 2.0)),
                            clockwise: false)
            context.closePath()
            context.fillPath()
            
            context.restoreGState()
        }
        
        // draw the end thumb last
        if let safeImage = self.thumbnailImage {
            let imageRect = CGRect(x: 2,
                                   y: 2,
                                   width: rect.size.width - 4,
                                   height: rect.size.height - 4)
            context.draw(safeImage, in: imageRect, byTiling: false)
        }
    }
}
