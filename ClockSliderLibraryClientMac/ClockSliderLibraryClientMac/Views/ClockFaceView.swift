//
//  ClockFaceView.swift
//  ClockSliderLibraryClientMac
//
//  Created by Jason Cross on 2024-10-27.
//

import Foundation
import Cocoa
import ClockSliderLibrary

class ClockFaceView: NSView {
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
    
    //MARK:- drawing
    override var isFlipped: Bool {
        return true
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        let safeRect = self.bounds
                
        guard let ctx = NSGraphicsContext.current?.cgContext else {
            return
        }
        
        self.underlyingClockFaceView.draw(safeRect, context: ctx)
    }
}
