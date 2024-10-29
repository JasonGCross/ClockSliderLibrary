//
//  ThumbnailViewModel.swift
//  ClockSliderLibrary
//
//  Created by Jason Cross on 2024-10-29.
//

import Foundation
import CoreGraphics


public struct ThumbnailViewModel {
    public var viewDelegate: CocoaCocoaTouchViewInterface?
    public var isHighlighted: Bool = false
    
    func touchPointIsInsideThisView(_ touchPoint: CGPoint) -> Bool {
        guard let safeDelegate = viewDelegate else { return false }
        return safeDelegate.touchPointIsInsideThisView(touchPoint)
    }
}


