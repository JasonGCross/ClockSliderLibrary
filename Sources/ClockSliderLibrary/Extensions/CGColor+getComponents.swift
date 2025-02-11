//
//  CGColor+getComponents.swift
//  ClockSliderLibrary
//
//  Created by Jason Cross on 2024-10-28.
//

import QuartzCore

extension CGColor {
    func getRed(
        _ red: UnsafeMutablePointer<CGFloat>?,
        green: UnsafeMutablePointer<CGFloat>?,
        blue: UnsafeMutablePointer<CGFloat>?,
        alpha: UnsafeMutablePointer<CGFloat>?
    ) {
        guard let safeComponents = self.components,
        safeComponents.count >= 4 else {
            return
        }
        
        red?.initialize(to: safeComponents[0])
        green?.initialize(to: safeComponents[1])
        blue?.initialize(to: safeComponents[2])
        alpha?.initialize(to: safeComponents[3])
    }
}
