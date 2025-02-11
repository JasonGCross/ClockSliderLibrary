//
//  ClockFaceView.swift
//  clock_slider_view
//
//  Created by Jason Cross on 3/19/18.
//  Copyright © 2018 Cross Swim Training, Inc. All rights reserved.
//


import UIKit

class ClockFaceView: UIView {
    
    var outerRingBackgroundColor : UIColor = UIColor(red: 0.086,
                                                     green: 0.094,
                                                     blue: 0.090,
                                                     alpha: 1.00)
    var innerRingBackgroundColor: UIColor = UIColor.black
    var fontAttributes : [NSAttributedString.Key : AnyObject]
    var tickMarkColor : UIColor = UIColor(red: 0.380,
                                          green: 0.380,
                                          blue: 0.380,
                                          alpha: 1.00)
    var omitClockFaceTicks: Bool = false
    var omitClockFaceHourMarkingDigits: Bool = false
    
    var clockRadius: CGFloat
    var ringWidth: CGFloat
    var clockFacePadding: CGFloat = 3
    var minutesBetweenMinorTickMarks: Int = 15
    let hourMarkLineLength: CGFloat = 5
    let hourMarkLineWidth : CGFloat = 2
    let minuteMarkLineWidth: CGFloat = 1
    let rotationEachHour : CGFloat
    var rotationEachMinorTick : CGFloat = CGFloat(Double.pi / 24)
    let numberOfHours = 12
    var customizedTwelveOClockCharacter: String?
    
    init(_frame: CGRect,
         _ringWidth: CGFloat) {
        ringWidth = _ringWidth
        rotationEachHour = CGFloat(CGFloat(2 * Double.pi) / CGFloat(self.numberOfHours))
        
        fontAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(red: 0.380,
                                                            green: 0.380,
                                                            blue: 0.380,
                                                            alpha: 1.00),
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)
        ]
        let diameter = CGFloat(fminf(Float(_frame.size.width),
                                     Float(_frame.size.height)))
        clockRadius = diameter / 2.0
        
        super.init(frame: _frame)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func draw(_ rect: CGRect) {
        
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return
        }
        ctx.saveGState()
        ctx.setShouldAntialias(true)
        
        // we want to do all the drawing using the center of the clock as the origin
        // to achieve this, translate the view
        ctx.translateBy(x: clockRadius, y: clockRadius)
        
        /**
         outer ring is actually an entire circle; we will place an inner circle on top to make it appear as a ring
         */
        ctx.beginPath()
        ctx.move(to: rect.origin)
        ctx.addArc(center: rect.origin,
                   radius: self.clockRadius,
                   startAngle: -CGFloat((Double.pi / 2.0)),
                   endAngle: CGFloat((2 * Double.pi) - (Double.pi / 2.0)),
                   clockwise: false)
        ctx.setFillColor(self.outerRingBackgroundColor.cgColor)
        ctx.fillPath()
        
        /**
         inner circle is the clock face itself
         */
        ctx.beginPath()
        ctx.move(to: rect.origin)
        ctx.addArc(center: rect.origin,
                   radius: clockRadius - self.ringWidth,
                   startAngle: -CGFloat((Double.pi / 2.0)),
                   endAngle: CGFloat((2 * Double.pi) - (Double.pi / 2.0)),
                   clockwise: false)
        ctx.setFillColor(self.innerRingBackgroundColor.cgColor)
        ctx.fillPath()
        
        //
        // line segments for hour and minute markings
        //
        ctx.setLineCap(CGLineCap.butt)
        self.tickMarkColor.setStroke()
        
        let hourMarkDistalPoint = CGPoint(x: rect.origin.x,
                                          y: rect.origin.y - clockRadius  + (self.ringWidth + self.clockFacePadding))
        let hourMarkProximalPoint = CGPoint(x: hourMarkDistalPoint.x,
                                            y:hourMarkDistalPoint.y + self.hourMarkLineLength)
        var hourMarkPath = CGMutablePath()
        
        //
        // minutes are fine markings
        //
        if (self.minutesBetweenMinorTickMarks > 0) {
            ctx.saveGState()
            ctx.setLineWidth(self.minuteMarkLineWidth)
            
            let numberOfMinorTicksRequired = 720 / self.minutesBetweenMinorTickMarks
            
            for _ in 1...numberOfMinorTicksRequired {
                ctx.rotate(by: self.rotationEachMinorTick)
                hourMarkPath.move(to: hourMarkDistalPoint)
                hourMarkPath.addLine(to: hourMarkProximalPoint)
                ctx.addPath(hourMarkPath)
                ctx.drawPath(using: CGPathDrawingMode.stroke)
            }
            ctx.restoreGState()
        }
        
        // for each hour, perform a rotation transformation on the path
        ctx.saveGState()
        ctx.setLineWidth(self.hourMarkLineWidth)
        
        for hour in 1...numberOfHours {
            ctx.rotate(by: rotationEachHour)
            if (self.omitClockFaceTicks == false) {
                hourMarkPath = CGMutablePath()
                hourMarkPath.move(to: hourMarkDistalPoint)
                hourMarkPath.addLine(to: hourMarkProximalPoint)
                ctx.addPath(hourMarkPath)
                ctx.drawPath(using: CGPathDrawingMode.stroke)
            }
            // for each "label", counter rotate so that the digits read in the normal orientation
            if (self.omitClockFaceHourMarkingDigits == false) {
                var textString : String = String(hour)
                if((hour == 12) && (self.customizedTwelveOClockCharacter != nil)) {
                    textString = self.customizedTwelveOClockCharacter!
                }
                
                let textSize : CGSize = textString.size(withAttributes: self.fontAttributes)
                let angleCorrection = CGFloat(-1.0 * CGFloat(hour) * rotationEachHour)
                let textBaseCenterPoint = CGPoint(x: hourMarkProximalPoint.x,
                                                  y: hourMarkProximalPoint.y + (textSize.height / 2) + self.clockFacePadding)
                print("hour mark: \(hourMarkProximalPoint), textBaseCenterPoint: \(textBaseCenterPoint)")
                
                textString.drawWithBasePoint(textBaseCenterPoint,
                                             angle:angleCorrection,
                                             fontAttributes: self.fontAttributes,
                                             context:ctx)
            }
        }
        ctx.restoreGState()
        ctx.restoreGState()
    }
    
}

