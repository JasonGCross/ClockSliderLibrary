//
//  CrossPlatformClockSliderView.swift
//  ClockSliderLibrary
//
//  Created by Jason Cross on 2024-10-28.
//

import Foundation
import CoreGraphics
import CoreText

public class CrossPlatformClockSliderView {
    
    public var viewModel: ClockSliderViewModel
    
    public init(viewModel: ClockSliderViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - drawing
    public func draw(_ dirtyRect: CGRect, context: CGContext) {
        let rect = dirtyRect
        
        // If you want to fill a shape with a shading, you use that shape to modify the clipping area to that shape and paint the shading. You can’t directly use a shading to stroke a shape, but you can achieve the equivalent effect in Tiger and later versions by using the function CGContextReplacePathWithStrokedPath to create a path whose interior is the area that would have been painted by stroking the current path. Clipping to the resulting path and then drawing the shading produces the same result as stroking with the shading.
        context.saveGState()
        
        context.setShouldAntialias(true)
        
        // we want to do all the drawing using the center of the clock as the origin
        // to achieve this, translate the view
        context.translateBy(x: viewModel.clockRadius, y: viewModel.clockRadius)
        
        context.setLineCap(CGLineCap.round)
        context.setLineWidth(self.viewModel.ringWidth)
        
        // drawArc only "works" under certain conditions:
        //  - moving from the start angle to the end angle must be in the positive direction
        //  - so always start with the start angle at 0
        //  - then adjust the end angle to be positive if required
        //  - don't interfere with the end angle if we don't have to
        let axisAdjustment = self.viewModel.sliderStartAngle - CGFloat((Double.pi / 2.0))
        context.rotate(by: axisAdjustment)
        var drawableEndAngle = self.viewModel.sliderEndAngle - self.viewModel.sliderStartAngle
        
        // when the start and finish hands are the same, we want the clock to draw a complete arc,
        // except when the hour is supposed to be zero -- in that case, we don't want any arc drawn
        if(abs(drawableEndAngle) < viewModel.angleEquivalentToOnePixel) {
            if (self.viewModel.clockDuration > viewModel.thresholdForAdjustingArcRaduis ){
                drawableEndAngle -= viewModel.angleEquivalentToOnePixel
            }
        }
        
        if (drawableEndAngle < 0) {
            drawableEndAngle += CGFloat(2.0 * Double.pi)
        }
        
        let useFirstRotationColors = (self.viewModel.clockRotationCount == .first)
        let startColor = useFirstRotationColors ? self.viewModel.firstDayGradientStartColor : self.viewModel.secondDayGradientStartColor
        
        let startRed = useFirstRotationColors ? self.viewModel.firstDayStartRed : self.viewModel.secondDayStartRed
        let startGreen = useFirstRotationColors ? self.viewModel.firstDayStartGreen : self.viewModel.secondDayStartGreen
        let startBlue = useFirstRotationColors ? self.viewModel.firstDayStartBlue : self.viewModel.secondDayStartBlue
        let endRed = useFirstRotationColors ? self.viewModel.firstDayEndRed : self.viewModel.secondDayEndRed
        let endGreen = useFirstRotationColors ? self.viewModel.firstDayEndGreen : self.viewModel.secondDayEndGreen
        let endBlue = useFirstRotationColors ? self.viewModel.firstDayEndBlue : self.viewModel.secondDayEndBlue
        
        // draw the slider colored donut segment in three stages:
        // 1. the start end cap
        // 2. the middle segment
        // 3. the finish end cap
        
        //
        // 1. the start end cap
        //
        let drawableStartAngle = CGFloat(0)
        context.beginPath()
        context.addArc(center: rect.origin,
                        radius: viewModel.radiusClockCenterToSliderTrackCenter,
                        startAngle: drawableStartAngle - self.viewModel.angleEquivalentToOnePixel,
                        endAngle: drawableStartAngle,
                        clockwise: false)
        context.setStrokeColor(startColor)
        context.strokePath()
        
        //
        // 2. the middle segment
        //
        // create a path whose interior is the area that would have been painted by stroking the current path
        context.beginPath()
        context.addArc(center: rect.origin,
                        radius: viewModel.radiusClockCenterToSliderTrackCenter,
                        startAngle: drawableStartAngle,
                        endAngle: drawableEndAngle,
                        clockwise: false)
        context.setStrokeColor(startColor)
        context.replacePathWithStrokedPath()
        
        // Clipping to the resulting path
        context.clip()
        
        // shade each "slice" of the donut using a different linear gradient
        
        // without this, there is a drawing bug which is visible by dark artifacts as part of the gradient
        // It appears as though the drawing routine is "skipping" some of the fill between sections
        // This is visible by setting the sliceOverlapToHideBorder to zero, and setting the
        // numberOfRequiredSlices to a small number (e.g. 5)
        let sliceOverlapToHideBorder = CGFloat(Double.pi / 120.0)
        
        let gradientStartAngle: CGFloat = drawableStartAngle
        let gradientEndAngle: CGFloat = drawableEndAngle - sliceOverlapToHideBorder
        let angleDifference: CGFloat = gradientEndAngle - gradientStartAngle
        let arcDistance: CGFloat = abs(angleDifference * viewModel.clockRadius)
        
        // how many slices do we need? assuming a screen resolution of 3X, select 3 x the arc distance
        var numberOfRequiredSlices: Int = abs(Int(round(arcDistance * viewModel.screenScale)))/10
        numberOfRequiredSlices = 36

        let angleIncrementPerSlice = min(abs(angleDifference / CGFloat(numberOfRequiredSlices)), 256)
        
        var sliceStartAngle: CGFloat = gradientStartAngle
        
        for sliceNumber in 0...numberOfRequiredSlices - 1 {
            context.saveGState()
            let fraction : CGFloat = CGFloat(sliceNumber + 1) / CGFloat(numberOfRequiredSlices)
            let sliceColor = CGColor.init(red: (fraction * endRed + (1-fraction) * startRed ),
                                     green: (fraction * endGreen + (1-fraction) * startGreen),
                                     blue: (fraction * endBlue + (1-fraction) * startBlue),
                                     alpha: 1)
            let sliceEndAngle = sliceStartAngle + angleIncrementPerSlice
            
            context.beginPath()
            context.move(to: rect.origin)
            context.addArc(center: rect.origin,
                            radius: viewModel.clockRadius,
                            startAngle: sliceStartAngle,
                            endAngle: sliceEndAngle + sliceOverlapToHideBorder,
                            clockwise: false)
            context.setFillColor(sliceColor)
            context.setStrokeColor(sliceColor)
            context.fillPath()
            
            context.restoreGState()
            
            // increment for next iteration
            sliceStartAngle = sliceEndAngle
        }
        context.restoreGState() // state started for the slider, closed here
        
        //
        // 3. the finish end cap
        //
        
        // handled by the control itself
        
        //
        // images for thumb sliders
        //
        
        // handled by the control itself
        
    }
}
