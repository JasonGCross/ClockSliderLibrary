//
//  ThumbnailViewModel.swift
//  ClockSliderLibrary
//
//  Created by Jason Cross on 2024-10-29.
//

import Foundation
import CoreGraphics


public class ThumbnailViewModel: NSObject {
    
    // Normally, inside AppKit or UIKit, one would simply use self.frame.contains to determine
    // if a touch point lies inside that view or not.
    // However, CoreGraphics does not have the concept of an NSView or UIView,
    // *and* it may be difficult to keep the AppKit or UIKit frame in sync with the
    // CrossPlatformThumbnailView's CGRect.
    // The work-around is to make the AppKit or UIKit view a delegate of the CrossPlatformThumbnailView
    // so that the higher level view can determine if self.frame.contains the touch point or not
    public var viewDelegate: CocoaCocoaTouchViewInterface?
    public var isHighlighted: Bool = false
    internal var drawableEndAngle: CGFloat = 0
    
    public init(drawableEndAngle: CGFloat) {
        self.drawableEndAngle = drawableEndAngle
    }
    
    func touchPointIsInsideThisView(_ touchPoint: CGPoint) -> Bool {
        guard let safeDelegate = viewDelegate else { return false }
        return safeDelegate.touchPointIsInsideThisView(touchPoint)
    }
}


