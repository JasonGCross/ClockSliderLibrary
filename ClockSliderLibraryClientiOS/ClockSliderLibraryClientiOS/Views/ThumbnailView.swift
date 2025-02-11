//
//  ThumbnailView.swift
//  ClockSliderLibraryClientiOS
//
//  Created by Jason Cross on 2024-10-29.
//

import UIKit
import ClockSliderLibrary

class ThumbnailView: UIView {
    var underlyingThumbnailView: CrossPlatformThumbnailView
    
    //MARK:- initialization
    override init(frame: CGRect) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(_frame: CGRect,
         _ringWidth: CGFloat,
         _clockRadius: CGFloat,
         _underlyingThumbnailView: CrossPlatformThumbnailView,
         _thumnailImage: UIImage? = nil,
         _thumbnailColor: UIColor? = nil
    ) {
        let thumnailImage: CGImage? = _thumnailImage?.cgImage
        let thumbnailColor: CGColor? = _thumbnailColor?.cgColor
        underlyingThumbnailView = _underlyingThumbnailView
        
        super.init(frame: _frame)
        self.backgroundColor = .clear
        
        underlyingThumbnailView.thumbnailImage = thumnailImage
        underlyingThumbnailView.thumbnailColor = thumbnailColor
        
        // need to se the CocoaCocoaTouchViewInterface view delegate for the touch gestures to work
        underlyingThumbnailView.viewModel.viewDelegate = self
    }

    //MARK:- Drawing    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
                
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return
        }
        
        self.underlyingThumbnailView.draw(rect, context: ctx)
    }
}

extension ThumbnailView: CocoaCocoaTouchViewInterface {
    public func touchPointIsInsideThisView(_ touchPoint: CGPoint) -> Bool {
        return self.frame.contains(touchPoint)
    }
}
