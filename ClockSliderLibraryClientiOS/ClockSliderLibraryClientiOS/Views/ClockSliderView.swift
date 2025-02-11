//
//  ClockSliderView.swift
//  ClockSliderLibraryClientiOS
//
//  Created by Jason Cross on 2024-10-28.
//

import UIKit
import ClockSliderLibrary

class ClockSliderView: UIView {
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
        
        self.backgroundColor = .clear
    }
    
    //MARK:- Helpers
    func originForThumbnail(minutes: Int) -> CGPoint {
        return self.underlyingClockSliderView.viewModel.originForThumbnail(minutes)
    }
    
    //MARK:- Drawing
    override func draw(_ rect: CGRect) {
        super.draw(rect)
                
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return
        }
        
        self.underlyingClockSliderView.draw(rect, context: ctx)
    }
}
