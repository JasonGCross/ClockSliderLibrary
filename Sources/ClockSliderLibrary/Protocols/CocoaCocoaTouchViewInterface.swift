//
//  CocoaCocoaTouchViewInterface.swift
//  ClockSliderLibrary
//
//  Created by Jason Cross on 2024-10-29.
//

import CoreGraphics

public protocol CocoaCocoaTouchViewInterface {
    func touchPointIsInsideThisView(_ touchPoint: CGPoint) -> Bool
}


