//
//  CrossPlatformClockFaceView.swift
//  ClockSliderLibrary
//
//  Created by Jason Cross on 2024-10-27.
//

import Foundation
import CoreGraphics
import CoreText

public class CrossPlatformClockFaceView {
    
    //
    // properties
    //
    public var viewModel: ClockFaceViewModel
    
    // Attempt to keep only things that directly deal with view layout
    // in this file (e.g. colors, widths, sizes).
    // Move any underlying data or calculations to the View Model.
    
    
    //MARK: font-related
    var fontSize : CGFloat = 14
    var fontFamilyNameString: String = "HelveticaNeue-Light"
    var fontColor: CGColor = CGColor.init(red: 0.380,
                                          green: 0.380,
                                          blue: 0.380,
                                          alpha: 1.00)
    
    var outerRingBackgroundColor : CGColor = CGColor.init(red: 0.8,
                                                     green: 0.8,
                                                     blue: 0.8,
                                                     alpha: 1.00)

    var tickMarkColor = CGColor.init(red: 0,
                                     green: 0,
                                     blue: 0,
                                     alpha: 1.0)
    var clockContainerColor = CGColor.init(red: 0.5,
                                           green: 0.5,
                                           blue: 0.5,
                                           alpha: 1.00)
    var clockFaceColor = CGColor.init(red: 1.0,
                                      green: 1.0,
                                      blue: 1.0,
                                      alpha: 1.0)

    public var handsColor = CGColor.init(red: 0.5,
                                  green: 0.5,
                                  blue: 0.5,
                                  alpha: 1.00)

    func defaultFont() -> CTFont  {
        var attr = Dictionary<String, Any>()
        if let systemFont = CTFontCreateUIFontForLanguage(CTFontUIFontType.system,
                                                          fontSize,
                                                          nil) {
            attr[kCTFontFamilyNameKey as String] = CTFontCopyFamilyName(systemFont)
        }
        else {
            attr[kCTFontFamilyNameKey as String] = fontFamilyNameString
        }
        attr[kCTFontSizeAttribute as String] = fontSize
        attr[kCTForegroundColorAttributeName as String] = fontColor
        let fontDescriptor: CTFontDescriptor = CTFontDescriptorCreateWithAttributes(attr as CFDictionary)
        let font = CTFontCreateWithFontDescriptor(fontDescriptor,
                                                  fontSize,
                                                  nil)
        
        return font
    }
    
    var clockRadius: CGFloat
    public var ringWidth: CGFloat
    var clockFacePadding: CGFloat = 3
    var minutesBetweenMinorTickMarks: Int = 15
    var hourMarkLineLength: CGFloat = 5
    var hourMarkLineWidth : CGFloat = 2
    var minuteMarkLineWidth: CGFloat = 1
    var rotationEachMinorTick : CGFloat = CGFloat(Double.pi / 24)
    let handsWidth = 2.0
    let minuteHandRatio = 0.99
    let hourHandRatio = 0.75
    
    public init(_frame: CGRect,
         _ringWidth: CGFloat,
         _viewModel: ClockFaceViewModel) {
        ringWidth = _ringWidth
        let diameter = CGFloat(fminf(Float(_frame.size.width),
                                     Float(_frame.size.height)))
        clockRadius = diameter / 2.0
        self.viewModel = _viewModel
    }
    
    private func drawHourLabel(ctLine: CTLine,
                               lineOffset: CGFloat,
                               text: String,
                               textSize: CGSize,
                               basePoint:CGPoint,
                               angle:CGFloat,
                               context:CGContext
    ) {
        context.saveGState()
        
        /// The graphics context passed in has been rotated with each segment / movement of the hour hand,
        /// and is sitting at the distal position of each tick mark.
        /// The numbers (labels) need to be moved inside the proximal position of each tick mark.
        /// The calculated position (relative to the tick mark) has been passed in as `basePoint`
        ///
        let distanceFromCenterTransform:CGAffineTransform = CGAffineTransform(
            translationX: basePoint.x,
            y: basePoint.y)
        
        /// The graphics context passed in has been rotated to draw the lines around the clock face.
        /// If the angle is not reverted, the bottom of each number will face the inside of the clock,
        /// rather than all numbers facing the bottom of the clock.
        let rotationTransformation:CGAffineTransform = CGAffineTransform(rotationAngle:angle)
        
        /// Text drawing is done starting at the left hand side of the glpyh(s). This ends up squashed
        /// against the 3 o'clock tick mark, and too far away fro the 9 o'clock tick mark.
        /// Fix: shift each run of text by half its width, therefore "centering" it next to the tick mark.
        /// They also end up vertically too close to 6 o'clock and too far from 12 o'clock.
        /// Fix: shift each run of text by half its height.
        let centerTextTransform = CGAffineTransform(
            translationX: -0.5 * textSize.width,
            y: -0.5 * textSize.height)
        
        /// Unsure why this is needed, but without it, all the numbers are too low (sit staggered off the clock)
        /// Note: this transformation is required only when using context.showGlyphs, and not CCTDrawLine
        let adjustYPositionTransform:CGAffineTransform = CGAffineTransform(
            translationX: 1,
            y: -clockRadius + self.ringWidth + 3 * textSize.height)
        
        /// The use of CTLine (which is created by a CTTypesetter) has un-expected behaviour.
        /// Each line is appened to the old line, resulting in drift from the expected origin.
        /// Fix: find out the drift and subtract it.
        /// Note: this transformation is required only when using CTDrawLine, and not context.showGlyphs
//        let lineOffsetTransform:CGAffineTransform = CGAffineTransform(
//            translationX: -1 * lineOffset,
//            y: 1)
        
        /// Because the original version of this code was written for iOS (UIKit),
        /// it needs to be flipped upside down to work with CoreGraphics for MacOS.
        let flipUpSideDownTransform:CGAffineTransform = CGAffineTransform(scaleX: 1, y: -1)
        
        context.concatenate(distanceFromCenterTransform)
        context.concatenate(rotationTransformation)
        context.concatenate(centerTextTransform)
        context.concatenate(adjustYPositionTransform)
        //context.concatenate(lineOffsetTransform)
        context.concatenate(flipUpSideDownTransform)
        
        let ctFont = defaultFont()
        let glyphs: [CGGlyph] = ClockFaceViewModel.getGlyphsFromString(text,
                                                                       usingFont: ctFont,
                                                                        context: context)
        var points: [CGPoint] = [CGPoint](repeating: CGPoint.zero, count: glyphs.count)
        for i in 0..<glyphs.count {
            // very rough math for figuring out the width of each "label"
            // i.e. a single digit is simply the text size passed in.
            // the double digits are narrow for the "1" and then wider for the second digit
            let x = basePoint.x + CGFloat(i) * 0.9 * (textSize.width / CGFloat(glyphs.count))
            let y = basePoint.y
            points[i] = CGPoint(x: x, y: y)
        }
        
        let fontName = CTFontCopyName(ctFont, kCTFontFamilyNameKey) as String? ?? fontFamilyNameString
        let cgFfont = CGFont(fontName as CFString)!
        context.setFont(cgFfont)
        // this line is needed or the fault will be rendered at size 0 (regardless of the font's internal fontSize!)
        context.setFontSize(fontSize)
        context.setFillColor(self.fontColor)
        
        context.showGlyphs(glyphs, at: points)
        //CTLineDraw(ctLine, context)
        
        context.restoreGState()
    }
    
    public func draw(_ dirtyRect: CGRect, context: CGContext) {
        context.setFillColor(clockContainerColor)
        let bg = CGPath(rect: dirtyRect, transform: nil)
        context.addPath(bg)
        context.fillPath()
        
        let diameter = CGFloat(fminf(Float(dirtyRect.size.width),
                                     Float(dirtyRect.size.height)))
        let clockRadius = diameter / 2.0
        context.saveGState()
        context.setShouldAntialias(true)
        
        // we want to do all the drawing using the center of the clock as the origin
        // to achieve this, translate the view
        context.translateBy(x: clockRadius, y: clockRadius)
        
        /**
         outer ring is actually an entire circle; we will place an inner circle on top to make it appear as a ring
         */
        context.beginPath()
        context.move(to: dirtyRect.origin)
        context.addArc(center: dirtyRect.origin,
                   radius: self.clockRadius,
                   startAngle: -CGFloat((Double.pi / 2.0)),
                   endAngle: CGFloat((2 * Double.pi) - (Double.pi / 2.0)),
                   clockwise: false)
        context.setFillColor(self.outerRingBackgroundColor)
        context.fillPath()
        
        /**
         inner circle is the clock face itself
         */
        context.beginPath()
        context.move(to: dirtyRect.origin)
        context.addArc(center: dirtyRect.origin,
                   radius: clockRadius - self.ringWidth,
                   startAngle: -CGFloat((Double.pi / 2.0)),
                   endAngle: CGFloat((2 * Double.pi) - (Double.pi / 2.0)),
                   clockwise: false)
        context.setFillColor(self.clockFaceColor)
        context.fillPath()
        
        // draw a very small center of the circle, to anchor the hands of the clock
        context.beginPath()
        context.move(to: dirtyRect.origin)
        context.addArc(center: dirtyRect.origin,
                   radius: 4.0,
                   startAngle: -CGFloat((Double.pi / 2.0)),
                   endAngle: CGFloat((2 * Double.pi) - (Double.pi / 2.0)),
                   clockwise: false)
        context.setFillColor(handsColor)
        context.fillPath()
        
        //
        // line segments for hour and minute markings
        //
        context.setLineCap(CGLineCap.butt)
        context.setStrokeColor(self.tickMarkColor)
        let hourMarkDistalPoint = CGPoint(x: dirtyRect.origin.x,
                                          y: dirtyRect.origin.y - clockRadius  + (self.ringWidth + self.clockFacePadding))
        let hourMarkProximalPoint = CGPoint(x: hourMarkDistalPoint.x,
                                            y:hourMarkDistalPoint.y + self.hourMarkLineLength)
        var hourMarkPath = CGMutablePath()
        
        //
        // minutes are fine markings
        //
        if (self.minutesBetweenMinorTickMarks > 0) {
            context.saveGState()
            context.setLineWidth(self.minuteMarkLineWidth)
            
            let numberOfMinorTicksRequired = (60 * self.viewModel.numberOfHours) / self.minutesBetweenMinorTickMarks
            
            for _ in 1...numberOfMinorTicksRequired {
                context.rotate(by: self.rotationEachMinorTick)
                hourMarkPath.move(to: hourMarkDistalPoint)
                hourMarkPath.addLine(to: hourMarkProximalPoint)
                context.addPath(hourMarkPath)
                context.drawPath(using: CGPathDrawingMode.stroke)
            }
            context.restoreGState()
        }
        
        // for each hour, perform a rotation transformation on the path
        context.saveGState()
        context.setLineWidth(self.hourMarkLineWidth)
        
        for hour in 1...viewModel.numberOfHours {
            context.rotate(by: self.viewModel.rotationEachHour)
            hourMarkPath = CGMutablePath()
            hourMarkPath.move(to: hourMarkDistalPoint)
            hourMarkPath.addLine(to: hourMarkProximalPoint)
            context.addPath(hourMarkPath)
            context.setStrokeColor(CGColor.init(gray: 0.0, alpha: 1.0))
            context.drawPath(using: CGPathDrawingMode.stroke)
            // for each "label", counter rotate so that the digits read in the normal orientation
            let textString : String = String(hour)
            
            var dictionaryAttributes = Dictionary<String, Any>()
            dictionaryAttributes[kCTForegroundColorAttributeName as String] = self.tickMarkColor
            dictionaryAttributes[kCTFontFamilyNameKey as String] = fontFamilyNameString
            dictionaryAttributes[kCTFontSizeAttribute as String] = fontSize
            let attributedString = CFAttributedStringCreate(kCFAllocatorDefault, textString as CFString, dictionaryAttributes as CFDictionary)!
            
            let line = CTLineCreateWithAttributedString(attributedString)
            let textPosition = CTLineGetImageBounds(line, context)
            let lineOffset = textPosition.origin.x
            let textSize : CGSize = textPosition.size
            
            let angleCorrection = CGFloat(-1.0 * CGFloat(hour) * viewModel.rotationEachHour)
            let textBaseCenterPoint = CGPoint(x: hourMarkProximalPoint.x,
                                              y: hourMarkProximalPoint.y + (1 * textSize.height) + self.clockFacePadding)
            
            self.drawHourLabel(
                ctLine: line,
                lineOffset: lineOffset,
                text: textString,
                textSize: textSize,
                basePoint: textBaseCenterPoint,
                angle: angleCorrection,
                context: context)
        }
        context.restoreGState()

        //
        // hands on the clock
        //
        let hour = Double(viewModel.clockTime.hour)
        let minute = Double(viewModel.clockTime.minute)
        context.setStrokeColor(self.handsColor)
        context.setLineWidth(self.handsWidth)
        let handsStartPoint = CGPoint.zero
        context.setLineCap(CGLineCap.butt)
        
        context.saveGState()
        let maxHandLength = clockRadius - self.ringWidth
        let minuteHandEndPoint = CGPoint(x: 0, y: -maxHandLength * minuteHandRatio)
        context.rotate(by: (minute / 60) * (2 * Double.pi))
        let minuteHandPath = CGMutablePath()
        minuteHandPath.move(to: handsStartPoint)
        minuteHandPath.addLine(to: minuteHandEndPoint)
        context.addPath(minuteHandPath)
        context.drawPath(using: CGPathDrawingMode.stroke)
        context.restoreGState()
        
        context.saveGState()
        let hourHandEndPoint = CGPoint(x: 0, y: -maxHandLength * hourHandRatio)
        let fractionalHour = hour + (minute / 60.0)
        context.rotate(by: (fractionalHour / Double(self.viewModel.numberOfHours)) * (2 * Double.pi))
        let hourHandPath = CGMutablePath()
        hourHandPath.move(to: handsStartPoint)
        hourHandPath.addLine(to: hourHandEndPoint)
        context.addPath(hourHandPath)
        context.drawPath(using: CGPathDrawingMode.stroke)
        context.restoreGState()
        
        // outer-most state
        context.restoreGState()
    }
}


