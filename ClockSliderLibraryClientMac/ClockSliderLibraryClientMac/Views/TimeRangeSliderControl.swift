//
//  TimeRangeSliderControl.swift
//  ClockSliderLibraryClientMac
//
//  Created by Jason Cross on 2024-10-29.
//

import AppKit
import ClockSliderLibrary

class TimeRangeSliderControl: NSControl {
    var underlyingTimeRangeSliderControl: CrossPlatformTimeRangeSliderControl?
    
    //MARK:- subviews
    var clockFaceView : ClockFaceView?
    var clockSliderView: ClockSliderView?
    var startKnobView: ThumbnailView?
    var finishKnobView: ThumbnailView?
    
    //MARK:- properties
    
    // Attempt to keep only things that directly deal with view layout
    // in this file (e.g. colors, widths, sizes).
    // Move any underlying data or calculations to the View Model.
    
    /**
     The color of the rectangle in which the clock sits (the square outside of the circle).
     */
    var clockContainerBackgroundColor: NSColor = NSColor(red: 0.086,
                                                                 green: 0.094,
                                                                 blue: 0.090,
                                                                 alpha: 1.00) {
        willSet {
            self.underlyingTimeRangeSliderControl?.clockContainerBackgroundColor = newValue.cgColor
        }
    }
    
    /**
     The color of the circular clock face, behind the hands, numbers, and tick marks.
     */
    var clockFaceBackgroundColor: NSColor = NSColor(red: 0.086,
                                                            green: 0.094,
                                                            blue: 0.090,
                                                            alpha: 1.00) {
        willSet {
            self.underlyingTimeRangeSliderControl?.clockFaceBackgroundColor = newValue.cgColor
        }
    }
    
    /**
     * The color of the track upon which the slider slides. This track is in a ring
     * shape, and is outside the clock face itself (the circle with numbers and marks).
     */
    var outerRingBackgroundColor : NSColor = NSColor(red: 0.086,
                                                     green: 0.094,
                                                     blue: 0.090,
                                                     alpha: 1.00) {
        willSet {
            self.underlyingTimeRangeSliderControl?.outerRingBackgroundColor = newValue.cgColor
        }
    }
    
    /**
     * The foreground color of the clock face tick marks.
     */
    var clockFaceTickMarkColor: NSColor = NSColor(red: 0.380,
                                                  green: 0.380,
                                                  blue: 0.380,
                                                  alpha: 1.00) {
        willSet {
            self.underlyingTimeRangeSliderControl?.clockFaceTickMarkColor = newValue.cgColor
        }
    }
    
    /**
     The stroke color of the hour hand and the minute hand
     */
    public var clockFaceHandsColor : NSColor = NSColor(red: 0,
                                                       green: 0,
                                                       blue: 0,
                                                       alpha: 1.00) {
        willSet {
            self.underlyingTimeRangeSliderControl?.clockFaceHandsColor = newValue.cgColor
        }
    }
    
    var clockFaceTextSize: Float = 14 {
        willSet {
            self.underlyingTimeRangeSliderControl?.clockFaceTextSize = newValue
        }
    }
    
    var elapsedTimeTextSize: Float = 20 {
        willSet {
            self.underlyingTimeRangeSliderControl?.elapsedTimeTextSize = newValue
        }
    }
    
    /**
     * The foreground color of the clock face digits.
     */
    var clockFaceTextColor: NSColor = NSColor(red: 0.380,
                                              green: 0.380,
                                              blue: 0.380,
                                              alpha: 1.00) {
        willSet {
            self.underlyingTimeRangeSliderControl?.clockFaceTextColor = newValue.cgColor
        }
    }
    
    var elapsedTimeTextColor: NSColor = NSColor(red: 0.380,
                                                green: 0.380,
                                                blue: 0.380,
                                                alpha: 1.00) {
        willSet {
            self.underlyingTimeRangeSliderControl?.elapsedTimeTextColor = newValue.cgColor
        }
    }
    
    var clockFaceFont: NSFont = NSFont.systemFont(ofSize: 14) {
        willSet {
            let fontName : CFString = CTFontCopyFamilyName(newValue).self
            let fontSize : CGFloat = CTFontGetSize(newValue)
            self.underlyingTimeRangeSliderControl?.clockFaceFont = CTFontCreateWithName(fontName,
                                                                                        fontSize,
                                                                                        nil)
        }
    }
    
    var clockFaceFontName: String? {
        willSet {
            if let safeName: String = newValue {
                let font : CTFont = CTFontCreateWithName(safeName as CFString,
                                                         CGFloat(self.clockFaceTextSize),
                                                         nil)
                self.clockFaceFont = font
            }
        }
    }
    
    var elapsedTimeFont: NSFont = NSFont.systemFont(ofSize: 20) {
        willSet {
            let fontName : CFString = CTFontCopyFamilyName(newValue).self
            let fontSize : CGFloat = CTFontGetSize(newValue)
            self.underlyingTimeRangeSliderControl?.elapsedTimeFont = CTFontCreateWithName(fontName,
                                                                                          fontSize,
                                                                                          nil)
        }
    }
    
    var fontFamilyNameString: String = "HelveticaNeue-Light" {
        willSet {
            self.underlyingTimeRangeSliderControl?.fontFamilyNameString = newValue
        }
    }
    
    /**
     * The image used for the thumbnail icon where the user places a finger to
     * drag the start location of the time range control.
     * This image should be 42 pixels and circular.
     * This image must be in the XCAssetCatalog.
     */
    var startThumbnailImage : NSImage? {
        willSet {
            self.underlyingTimeRangeSliderControl?.startThumbnailImage = newValue?.cgImage(forProposedRect: nil, context: nil, hints: nil)
        }
    }
    
    /**
     * The color used in lieu of a thumbnail icon where the user places a finger to
     * drag the start location of the time range control.
     */
    var startThumbColor: NSColor = NSColor.systemBlue {
        willSet {
            self.underlyingTimeRangeSliderControl?.startKnobView?.thumbnailColor = newValue.cgColor
        }
    }
    
    /**
     * The image used for the thumbnail icon where the user places a finger to
     * drag the end location of the time range control.
     * This image should be 42 pixels and circular.
     * This image must be in the XCAssetCatalog.
     */
    var finishTumbnailImage : NSImage?  {
        willSet {
            self.underlyingTimeRangeSliderControl?.finishTumbnailImage = newValue?.cgImage(forProposedRect: nil, context: nil, hints: nil)
        }
    }
    
    /**
     * The color used in lieu of a thumbnail icon where the user places a finger to
     * drag the end location of the time range control.
     */
    var finishThumbColor: NSColor = NSColor.systemBlue {
        willSet {
            self.underlyingTimeRangeSliderControl?.finishKnobView?.thumbnailColor = newValue.cgColor
        }
    }

    /**
     * One of two colors which comprise the gradient used to fill the slider track.
     * The track uses this primary color scheme when the time span is between 0 and 12 hours.
     * This color is closest to the start position.
     */
    var firstDayGradientStartColor : NSColor = NSColor(red: 0.933,
                                                       green: 0.424,
                                                       blue: 0.149,
                                                       alpha: 1.00) {
        willSet {
            self.underlyingTimeRangeSliderControl?.firstDayGradientStartColor = newValue.cgColor
        }
    }
    
    /**
     * One of two colors which comprise the gradient used to fill the slider track.
     * The track uses this primary color scheme when the time span is between 0 and 12 hours.
     * This color is closest to the finish position.
     */
    @IBInspectable
    var firstDayGradientFinishColor : NSColor = NSColor(red: 0.965,
                                                        green: 0.965,
                                                        blue: 0.065,
                                                        alpha: 1.00) {
        willSet {
            self.underlyingTimeRangeSliderControl?.firstDayGradientFinishColor = newValue.cgColor
        }
    }
    
    /**
     * One of two colors which comprise the gradient used to fill the slider track.
     * The track switches to this alternate color scheme when the time span is between 12 and 24 hours.
     * This color is closest to the start position.
     */
    @IBInspectable
    var secondDayGradientStartColor : NSColor = NSColor(red: 0.072,
                                                        green: 0.878,
                                                        blue: 0.087,
                                                        alpha: 1.00) {
        willSet {
            self.underlyingTimeRangeSliderControl?.secondDayGradientStartColor = newValue.cgColor
        }
    }
    
    /**
     * One of two colors which comprise the gradient used to fill the slider track.
     * The track switches to this alternate color scheme when the time span is between 12 and 24 hours.
     * This color is closest to the finish position.
     */
    @IBInspectable
    var secondDayGradientFinishColor : NSColor = NSColor(red: 0.833,
                                                         green: 0.994,
                                                         blue: 0.342,
                                                         alpha: 1.00) {
        willSet {
            self.underlyingTimeRangeSliderControl?.secondDayGradientFinishColor = newValue.cgColor
        }
    }
    
    //MARK:- initialization
    override init(frame: CGRect) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(
        _frame: CGRect,
        _ringWidth: CGFloat,
        _clockType: ClockType,
        _timeOfDay: TimeOfDayModel,
        _sliderStartTime: TimeOfDayModel,
        _sliderEndTime: TimeOfDayModel) {
            super.init(frame: _frame)
            
            let screenScale = NSScreen.main?.backingScaleFactor ?? 1.0
            self.underlyingTimeRangeSliderControl = CrossPlatformTimeRangeSliderControl(
                _frame: _frame,
                _ringWidth: _ringWidth,
                _clockType: _clockType,
                _timeOfDay: _timeOfDay,
                _sliderStartTime: _sliderStartTime,
                _sliderEndTime: _sliderEndTime,
                _screenScale: screenScale
            )
            
            // access the 4 underlying (cross-platform) views and pass these to the AppKit views
            // using dependency injection
            let underlyingClockFaceView = self.underlyingTimeRangeSliderControl!.clockFaceView!
            let underlyingClockSliderView = self.underlyingTimeRangeSliderControl!.clockSliderView!
            let underlyingStartKnobView = self.underlyingTimeRangeSliderControl!.startKnobView!
            let underlyingFinishKnobView = self.underlyingTimeRangeSliderControl!.finishKnobView!
            
            // the inner circle with the hands, ticks, and numbers
            self.clockFaceView = ClockFaceView(
                _frame: _frame,
                _ringWidth: _ringWidth,
                _underlyingClockFaceView: underlyingClockFaceView
            )
        
            // the outer ring with a track for sliding
            let startAngle = self.underlyingTimeRangeSliderControl!.viewModel.getDrawableStartAngle()
            let finishAngle = self.underlyingTimeRangeSliderControl!.viewModel.getDrawableEndAngle()
            self.clockSliderView = ClockSliderView(
                _frame: _frame,
                _ringWidth: _ringWidth,
                _sliderStartAngle: startAngle,
                _sliderEndAngle: finishAngle,
                _clockType: _clockType,
                _clockRotationCount: .first,
                _underlyingClockSliderView: underlyingClockSliderView
            )
            
            // the sliders along the track
            let diameter = CGFloat(fminf(Float(frame.size.width),
                                         Float(frame.size.height)))
            let clockRadius = diameter / 2.0
            let startThumbnailOrigin = clockSliderView!.originForThumbnail(minutes:_sliderStartTime.totalMinutes)
            let startThumbnailFrame = CGRect(x: startThumbnailOrigin.x, y: startThumbnailOrigin.y, width: _ringWidth, height: _ringWidth)
            self.startKnobView = ThumbnailView(
                _frame: startThumbnailFrame,
                _ringWidth: _ringWidth,
                _clockRadius: clockRadius,
                _underlyingThumbnailView: underlyingStartKnobView,
                _thumbnailColor: NSColor.red
            )
        
            let finishThumbnailOrigin = clockSliderView!.originForThumbnail(minutes:_sliderEndTime.totalMinutes)
            let finishThumbnailFrame = CGRect(x: finishThumbnailOrigin.x, y: finishThumbnailOrigin.y, width: _ringWidth, height: _ringWidth)
            self.finishKnobView = ThumbnailView(
                _frame: finishThumbnailFrame,
                _ringWidth: _ringWidth,
                _clockRadius: clockRadius,
                _underlyingThumbnailView: underlyingFinishKnobView,
                _thumbnailColor: NSColor.green
            )
            
            self.addSubview(clockFaceView!)
            self.addSubview(clockSliderView!)
            self.addSubview(startKnobView!)
            self.addSubview(finishKnobView!)
            
            let pan = NSPanGestureRecognizer(target: self, action: #selector(pan))
            self.addGestureRecognizer(pan)
    }
    
    //MARK: - helpers
    internal func updateThumbLayers() -> Void {
        guard let safeSliderView = self.clockSliderView,
              let safeStartKnobView = self.startKnobView,
              let safeFinishKnobView = self.finishKnobView,
              let safeUnderlyingTimeRangeSliderControl = self.underlyingTimeRangeSliderControl else {
            return
        }
        
        let startMinutes = safeUnderlyingTimeRangeSliderControl.getStartTime().totalMinutes
        let finishMinutes = safeUnderlyingTimeRangeSliderControl.getFinishTime().totalMinutes
        let originForStartSlider = safeSliderView.originForThumbnail(minutes: startMinutes)
        let originForFinishSlider = safeSliderView.originForThumbnail(minutes: finishMinutes)
        safeStartKnobView.frame.origin = originForStartSlider
        safeFinishKnobView.frame.origin = originForFinishSlider
        
//        let clockRotationCount = safeUnderlyingTimeRangeSliderControl.getClockRotationCount()
//        let useFirstRotationColors = (clockRotationCount == .first)
//        let finishColor = useFirstRotationColors ? self.firstDayGradientFinishColor : self.secondDayGradientFinishColor
        
//        let sliderEndAngle = safeUnderlyingTimeRangeSliderControl.getSliderEndAngle()
//        safeFinishKnobView.setDrawableEndAngle(sliderEndAngle)
//        self.finishThumbColor = finishColor
        safeFinishKnobView.setNeedsDisplay(safeFinishKnobView.bounds)
        safeStartKnobView.setNeedsDisplay(safeStartKnobView.bounds)
        
        // drawing order should take into account which end is highlighted
        // note: last drawn is on top (higher Z-index)
        if ((safeUnderlyingTimeRangeSliderControl.viewModel.lastDraggedThumbKnob == HighlightedKnob.finish) &&
            (safeUnderlyingTimeRangeSliderControl.viewModel.thumbWithHigherZIndex != HighlightedKnob.finish)) {
            safeFinishKnobView.removeFromSuperview()
            safeStartKnobView.removeFromSuperview()
            self.addSubview(safeStartKnobView)
            self.addSubview(safeFinishKnobView)
            safeUnderlyingTimeRangeSliderControl.viewModel.thumbWithHigherZIndex = HighlightedKnob.finish
        }
        else if ((safeUnderlyingTimeRangeSliderControl.viewModel.lastDraggedThumbKnob == HighlightedKnob.start) &&
            (safeUnderlyingTimeRangeSliderControl.viewModel.thumbWithHigherZIndex != HighlightedKnob.start)) {
            safeFinishKnobView.removeFromSuperview()
            safeStartKnobView.removeFromSuperview()
            self.addSubview(safeFinishKnobView)
            self.addSubview(safeStartKnobView)
            safeUnderlyingTimeRangeSliderControl.viewModel.thumbWithHigherZIndex = HighlightedKnob.start
        }
    }
    
    //MARK: - drawing
    //*************************************************************************
    
    override var isFlipped: Bool {
        return true
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        let safeRect = self.bounds
                
        guard let ctx = NSGraphicsContext.current?.cgContext,
              let underlyingView = self.underlyingTimeRangeSliderControl else {
            return
        }
        
        underlyingView.draw(safeRect, context: ctx)
        
        // force sub-views to redraw
        
        // the clock face
        self.clockFaceView?.setNeedsDisplay(self.clockFaceView?.bounds ?? self.bounds)
        
        // the slider
        self.clockSliderView?.setNeedsDisplay(self.clockSliderView?.bounds ?? self.bounds)
        
        // the thumbs
        self.updateThumbLayers()
    }
    
    //MARK: - touch handling
    //*************************************************************************
      
    @objc func pan(pan: NSClickGestureRecognizer) {
        guard let viewModel = self.underlyingTimeRangeSliderControl?.viewModel else {
            return
        }
        
        let location: NSPoint = pan.location(in: self)
        
        switch pan.state {
        case .began:
            viewModel.beginTracking(at: location)
            break
        case .changed:
            viewModel.continueTracking(location: location)
            break
        case .ended:
            viewModel.endTracking(location: location)
            // this line makes this control act like a control,
            // sending a message via an IBAction
            // when the appropriate event occurs
            self.sendAction(self.action, to: self.target)
            break
        default:
            break
        }
        
        self.setNeedsDisplay(self.bounds)
    }
}
