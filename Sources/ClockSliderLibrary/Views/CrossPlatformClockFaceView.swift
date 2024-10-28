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
    
    var outerRingBackgroundColor : CGColor = CGColor.init(red: 0.8,
                                                     green: 0.8,
                                                     blue: 0.8,
                                                     alpha: 1.00)
    var innerRingBackgroundColor: CGColor = CGColor.init(red: 0.4,
                                                         green: 0.4,
                                                         blue: 0.4,
                                                         alpha: 1.00)

    var tickMarkColor = CGColor.init(red: 0,
                                     green: 0,
                                     blue: 0,
                                     alpha: 1.0)
    var clockFaceColor = CGColor.init(red: 1.0,
                                       green: 1.0,
                                       blue: 1.0,
                                       alpha: 1.0)
    var yellowColor = CGColor.init(red: 0.999, green: 0.986, blue: 0.000, alpha: 1.00)
    let handsColor = CGColor.init(red: 0.999, green: 0.986, blue: 0.000, alpha: 1.00)
    var defaultFontSize : CGFloat = 14
    var fontFamilyNameString: String = "HelveticaNeue-Light"
    var defaultFont: CGFont {
        CGFont(self.fontFamilyNameString as CFString)!
    }
    var clockRadius: CGFloat
    var ringWidth: CGFloat
    var clockFacePadding: CGFloat = 3
    var minutesBetweenMinorTickMarks: Int = 15
    let hourMarkLineLength: CGFloat = 5
    let hourMarkLineWidth : CGFloat = 2
    let minuteMarkLineWidth: CGFloat = 1
    var rotationEachMinorTick : CGFloat = CGFloat(Double.pi / 24)
    var clockType: ClockType = .twelveHourClock
    var numberOfHours: Int { self.clockType.rawValue }
    var rotationEachHour: CGFloat { CGFloat(CGFloat(2 * Double.pi) / CGFloat(clockType.rawValue)) }

    let handsWidth = 2.0
    var clockTime = TimeOfDayModel.now
    let minuteHandRatio = 0.83
    let hourHandRatio = 0.65
    
    public init(_frame: CGRect,
         _ringWidth: CGFloat) {
        ringWidth = _ringWidth
        let diameter = CGFloat(fminf(Float(_frame.size.width),
                                     Float(_frame.size.height)))
        clockRadius = diameter / 2.0
    }
    
    public func draw(_ dirtyRect: CGRect, context: CGContext) {
        context.setFillColor(yellowColor)
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
        context.setFillColor(self.innerRingBackgroundColor)
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
            
            let numberOfMinorTicksRequired = (60 * self.numberOfHours) / self.minutesBetweenMinorTickMarks
            
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
        
        var cumulativeLineWidth : CGFloat = 0.0
        for hour in 1...numberOfHours {
            context.rotate(by: rotationEachHour)
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
            dictionaryAttributes[kCTFontFamilyNameKey as String] = self.fontFamilyNameString
            dictionaryAttributes[kCTFontSizeAttribute as String] = self.defaultFontSize
            let attributedString = CFAttributedStringCreate(kCFAllocatorDefault, textString as CFString, dictionaryAttributes as CFDictionary)!
            let line = CTLineCreateWithAttributedString(attributedString)
            let textPosition = CTLineGetImageBounds(line, context)
            let textSize : CGSize = textPosition.size
            
            let angleCorrection = CGFloat(-1.0 * CGFloat(hour) * rotationEachHour)
            let textBaseCenterPoint = CGPoint(x: hourMarkProximalPoint.x,
                                              y: hourMarkProximalPoint.y + (1 * textSize.height) + self.clockFacePadding)
            
            let t:CGAffineTransform   =   CGAffineTransform(translationX: textBaseCenterPoint.x, y: textBaseCenterPoint.y)
            let r:CGAffineTransform   =   CGAffineTransform(rotationAngle:angleCorrection)
            let fudgeFactor:CGAffineTransform   =   CGAffineTransform(translationX: 1.35 * -cumulativeLineWidth, y: (0.5 * textSize.height))
            let s:CGAffineTransform   =   CGAffineTransform(scaleX: 1, y: -1)
            
            context.concatenate(t)
            context.concatenate(r)
            context.concatenate(fudgeFactor)
            context.concatenate(s)
            
            // This is a convenience function because the line could be drawn run-by-run by getting the glyph runs, getting the glyphs out of them, and calling a function such as showGlyphs(_:atPositions:count:). This call can leave the graphics context in any state and does not flush the context after the draw operation.
            // attempting to flush or restore the graphics context did not fix the issue of the next line drawn
            // starting where the old one left off. To fix this, added a fudge factor
            CTLineDraw(line, context)
            cumulativeLineWidth += textPosition.width
        
            context.concatenate(s.inverted())
            context.concatenate(fudgeFactor.inverted())
            context.concatenate(r.inverted())
            context.concatenate(t.inverted())
        }
        context.restoreGState()

        //
        // hands on the clock
        //
        let hour = Double(clockTime.hour)
        let minute = Double(clockTime.minute)
        context.setStrokeColor(self.handsColor)
        context.setLineWidth(self.handsWidth)
        let handsStartPoint = CGPoint.zero
        context.setLineCap(CGLineCap.butt)
        
        context.saveGState()
        let minuteHandEndPoint = CGPoint(x: 0, y: -clockRadius * minuteHandRatio)
        context.rotate(by: (minute / 60) * (2 * Double.pi))
        let minuteHandPath = CGMutablePath()
        minuteHandPath.move(to: handsStartPoint)
        minuteHandPath.addLine(to: minuteHandEndPoint)
        context.addPath(minuteHandPath)
        context.drawPath(using: CGPathDrawingMode.stroke)
        context.restoreGState()
        
        context.saveGState()
        let hourHandEndPoint = CGPoint(x: 0, y: -clockRadius * hourHandRatio)
        context.rotate(by: (hour / Double(self.numberOfHours)) * (2 * Double.pi))
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
