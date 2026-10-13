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

#Preview {
    let frame = CGRect(x: 0, y: 0, width: 200, height: 200)
    let ringWidth: CGFloat = 200
    let vm = ClockFaceViewModel()
    let crossPlatformClockFace: CrossPlatformClockFaceView = CrossPlatformClockFaceView(_frame: CGRect(x: 0, y: 0, width: 100, height: 100), _ringWidth: ringWidth, _viewModel: vm)
    ClockFaceView(_frame: frame, _ringWidth: ringWidth, _underlyingClockFaceView: crossPlatformClockFace)
}
