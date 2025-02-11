//
//  CGPoint+closestInterceptPointToCircle.swift
//  clock_slider_view
//
//  Created by Jason Cross on 3/19/18.
//  Copyright © 2018 Cross Swim Training, Inc. All rights reserved.
//


import QuartzCore

extension CGPoint {
    func closestInterceptPointToCircle(_ circleCenter: CGPoint,
                                       circleXIntercept: CGFloat,
                                       circleYIntercept: CGFloat,
                                       circleRadius: CGFloat) -> CGPoint {
        
        // general formula for a circle is
        // (x - h)^2 + (y - k)^2 = radius^2
        // where h,k are the coordinates of the center
        let h = circleCenter.x
        let k = circleCenter.y
        let r = circleRadius
        
        var intercept1: CGPoint = circleCenter
        var intercept2: CGPoint = circleCenter
        
        
        // Find the equation for the line between origin and drag point
        // y = mx + b
        // m => slope
        // b => y-intercept
        
        // be careful because we may have infinite slope
        if ((self.x - circleCenter.y) == 0) {
            // line equation is now more simple:
            // x = circleXIntercept
            //
            // general formula for a circle is
            // (x - h)^2 + (y - k)^2 = radius^2
            // substituting x = h gives
            // r^2 = (h - h)^2 + (y - k)^2
            //
            // where the quadradic formula is
            // 0 = x^2 * a + (b * x) + c
            //
            // rearranging into the familiar quadradic form gives
            // 0 = y^2 - 2ky + k^2 - r^2
            // a => 1
            // b => -2k
            // c => k^2 - r^2
            let B: CGFloat = -CGFloat(2.0 * k)
            let c: CGFloat = CGFloat((k*k) - (r*r))
            
            // quadratic formula:
            // x = (-B +/- root( B^2 - (4*a*c))) / 2a
            let root: CGFloat = sqrt(B*B - CGFloat(4.0 * c))
            let y1: CGFloat = (-B + root) / CGFloat(2)
            let y2: CGFloat = (-B - root) / CGFloat(2)
            
            // now solve for x in each case
            let x1: CGFloat = h
            let x2: CGFloat = h
            
            intercept1 = CGPoint(x:x1, y:y1)
            intercept2 = CGPoint(x:x2, y:y2)
        }
        else {
            let m: CGFloat =  (self.y - circleCenter.y) / (self.x - circleCenter.y)
            let b: CGFloat = self.y - (m * self.x)
            
            
            // expanding the equation for the circle gives
            // r^2 = x^2 - 2*h*x + h^2 + y^2 - s*k*y + k^2
            // substituting y = mx+b gives
            // r^2 = x^2 - 2*h*x + h^2 + (m*x +b)^2 - s*k*(m*x +b) + k^2
            // r^2 = x^2 - 2*h*x + h^2 + (m^2)*(x^2) + 2m*x*b + b^2 - s*k*m*x + s*kb + k^2
            // r^2 = x^2 + (x^2)*(m^2) - 2*h*x - s*k*m*x + 2m*x*b + h^2 + b^2 + s*kb + k^2
            // r^2 = x^2 *(1 + m^2) - x *(-2*h + 2*b*m - 2*k*m) + h^2 - 2*k*b + k^2
            // now we can rephrase this as the quadradic formula
            // 0 = x^2 * a + (b * x) + c
            // 0 = x^2 * (1 + m^2) + x * 2*(-h + b*m - k*m) + h^2 - 2*k*b + k^2 - r^2
            let a: CGFloat = (1.0 + (m * m))
            let B: CGFloat = 2.0 * ((b*m) - h - (k*m))
            let c: CGFloat = (h*h) - (2.0*k*b) + (k*k) - (r*r)
            
            // quadratic formula:
            // x = (-B +/- root( B^2 - (4*a*c))) / 2a
            let x1: CGFloat = (-B + sqrt(B*B - CGFloat(4.0*a*c))) / (2.0*a)
            let x2: CGFloat = (-B - sqrt(B*B - CGFloat(4.0*a*c))) / (2.0*a)
            
            // now solve for y in each case
            // y = mx + b
            let y1: CGFloat = (m * x1) + b
            let y2: CGFloat = (m * x2) + b
            
            intercept1 = CGPoint(x:x1, y:y1)
            intercept2 = CGPoint(x:x2, y:y2)
        }
        
        // which is closer?
        let distance1 = self.distanceToPoint(intercept1)
        let distance2 = self.distanceToPoint(intercept2)
        
        let closestIntercept = distance1 <= distance2 ? intercept1 : intercept2
        
        return closestIntercept;
    }
}

