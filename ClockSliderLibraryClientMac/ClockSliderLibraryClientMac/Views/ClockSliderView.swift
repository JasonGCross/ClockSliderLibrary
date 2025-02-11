//
//  ClockSliderView.swift
//  ClockSliderLibraryClientMac
//
//  Created by Jason Cross on 2024-10-28.
//

import Foundation
import Cocoa
import ClockSliderLibrary

class ClockSliderView: NSView {
    var underlyingClockSliderView: CrossPlatformClockSliderView
    
    //MARK:- Initialization
    override init(frame: CGRect) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(_frame: CGRect,
         _ringWidth: CGFloat,
         _sliderStartAngle: CGFloat,
         _sliderEndAngle: CGFloat,
         _clockType: ClockType,
         _clockRotationCount: ClockRotationCount,
         _underlyingClockSliderView: CrossPlatformClockSliderView) {
        
        underlyingClockSliderView = _underlyingClockSliderView
        
        super.init(frame: _frame)
    }
    
    //MARK:- Drawing
    override var isFlipped: Bool {
        return true
    }
    
    func originForThumbnail(minutes: Int) -> CGPoint {
        return self.underlyingClockSliderView.viewModel.originForThumbnail(minutes)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        let safeRect = self.bounds
                
        guard let ctx = NSGraphicsContext.current?.cgContext else {
            return
        }
        
        self.underlyingClockSliderView.draw(safeRect, context: ctx)
    }
}
