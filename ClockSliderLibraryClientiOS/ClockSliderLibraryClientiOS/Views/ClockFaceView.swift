//
//  ClockFaceView.swift
//  ClockSliderLibraryClientiOS
//
//  Created by Jason Cross on 2024-10-27.
//

import UIKit
import ClockSliderLibrary

class ClockFaceView: UIView {
    var underlyingClockFaceView: CrossPlatformClockFaceView
    
    //MARK: - initialization
    override init(frame: CGRect) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(_frame: CGRect,
         _ringWidth: CGFloat,
         _underlyingClockFaceView : CrossPlatformClockFaceView
    ) {
        self.underlyingClockFaceView = _underlyingClockFaceView
        self.underlyingClockFaceView.ringWidth = _ringWidth
        
        super.init(frame: _frame)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
                
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return
        }
        
        self.underlyingClockFaceView.draw(rect, context: ctx)
    }
}
