//
//  CGPoint+distanceToPoint.swift
//  clock_slider_view
//
//  Created by Jason Cross on 3/19/18.
//  Copyright © 2018 Cross Swim Training, Inc. All rights reserved.
//

import Foundation

extension CGPoint {
    func distanceToPoint(_ point: CGPoint) -> CGFloat {
        let xDistance = self.x - point.x
        let yDistance = self.y - point.y
        let sumOfSides = (xDistance * xDistance) + (yDistance * yDistance)
        let value = sqrt(sumOfSides)
        return CGFloat(value)
    }
}
