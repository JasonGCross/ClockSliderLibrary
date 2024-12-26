//
//  CrossPlatformTimeRangeSliderControl.swift
//  ClockSliderLibrary
//
//  Created by Jason Cross on 2024-12-21.
//

import Foundation
import CoreGraphics
import CoreText

public class CrossPlatformTimeRangeSliderControl {
    
    //
    // View Model
    //
    public var viewModel: TimeRangeSliderControlViewModel
    
    //
    // Sub-views
    //
    var clockFaceView: CrossPlatformClockFaceView?
    var startKnobView: CrossPlatformThumbnailView?
    var finishKnobView: CrossPlatformThumbnailView?
    public var clockSliderView: CrossPlatformClockSliderView?
    
    //
    // properties
    //
    
    // Attempt to keep only things that directly deal with view layout
    // in this file (e.g. colors, widths, sizes).
    // Move any underlying data or calculations to the View Model.
    
    /**
     * The color of the track upon which the slider slides. This track is in a ring
     * shape, and is outside the clock face itself (the circle with numbers and marks).
     */
    var outerRingBackgroundColor : CGColor = CGColor.init(red: 0.086,
                                                     green: 0.094,
                                                     blue: 0.090,
                                                     alpha: 1.00) {
        willSet {
            self.clockFaceView?.outerRingBackgroundColor = newValue
        }
    }
    
    /**
     * The color of the clock face itself (the circle with numbers and marks).
     */
    var innerRingBackgroundColor: CGColor = CGColor.black {
        willSet {
            self.clockFaceView?.innerRingBackgroundColor = newValue
        }
    }
    
    /**
     * The foreground color of the clock face tick marks.
     */
    var clockFaceTickMarkColor: CGColor = CGColor.init(red: 0.380,
                                                  green: 0.380,
                                                  blue: 0.380,
                                                  alpha: 1.00) {
        willSet {
            self.clockFaceView?.tickMarkColor = newValue
        }
    }
    
    var clockFaceTextSize: Float = 14 {
        willSet {
            clockFaceFontAttributes[kCTFontSizeAttribute as String] = CGFloat(newValue)
        }
    }
    
    var elapsedTimeTextSize: Float = 20 {
        willSet {
            elapsedTimeFontAttributes[kCTFontSizeAttribute as String] = CGFloat(newValue)
        }
    }
    
    /**
     * The foreground color of the clock face digits.
     */
    var clockFaceTextColor: CGColor = CGColor.init(red: 0.380,
                                              green: 0.380,
                                              blue: 0.380,
                                              alpha: 1.00) {
        willSet {
            clockFaceFontAttributes[kCTForegroundColorAttributeName as String] = newValue
        }
    }
    
    var elapsedTimeTextColor: CGColor = CGColor.init(red: 0.380,
                                                green: 0.380,
                                                blue: 0.380,
                                                alpha: 1.00) {
        willSet {
            elapsedTimeFontAttributes[kCTForegroundColorAttributeName as String] = newValue
        }
    }
    
    var clockFaceFont: CTFont = CTFontCreateUIFontForLanguage(CTFontUIFontType.system,
                                                              14,
                                                              nil) ??
    CTFontCreateWithName("SF Pro Text" as CFString,
                                                     14,
                                                     nil) {
        willSet {
            clockFaceFontAttributes[kCTFontFamilyNameKey as String] = CTFontCopyFamilyName(newValue)
            clockFaceFontAttributes[kCTFontSizeAttribute as String] = CTFontGetSize(newValue)
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
    
    var elapsedTimeFont: CTFont = CTFontCreateUIFontForLanguage(CTFontUIFontType.system,
                                                                20,
                                                                nil) ??
    CTFontCreateWithName("SF Pro Text" as CFString, 20, nil) {
        willSet {
            elapsedTimeFontAttributes[kCTFontFamilyNameKey as String] = CTFontCopyFamilyName(newValue)
            elapsedTimeFontAttributes[kCTFontSizeAttribute as String] = CTFontGetSize(newValue)
        }
    }
    
    var clockFaceFontAttributes = Dictionary<String, Any>() {
        willSet {
            self.clockFaceView?.fontAttributes = newValue
        }
    }
    
    var elapsedTimeFontAttributes  = Dictionary<String, Any>()
    
    
    var fontFamilyNameString: String = "HelveticaNeue-Light" {
        willSet {
            clockFaceFontAttributes[kCTFontFamilyNameKey as String] = newValue as CFString
        }
    }
    
    /**
     * The image used for the thumbnail icon where the user places a finger to
     * drag the start location of the time range control.
     * This image should be 42 pixels and circular.
     * This image must be in the XCAssetCatalog.
     */
    var startThumbnailImage : CGImage? {
        willSet {
            self.startKnobView?.thumbnailImage = newValue
        }
    }
    
    /**
     * The image used for the thumbnail icon where the user places a finger to
     * drag the end location of the time range control.
     * This image should be 42 pixels and circular.
     * This image must be in the XCAssetCatalog.
     */
    var finishTumbnailImage : CGImage?  {
        willSet {
            self.finishKnobView?.thumbnailImage = newValue
        }
    }

    /**
     * One of two colors which comprise the gradient used to fill the slider track.
     * The track uses this primary color scheme when the time span is between 0 and 12 hours.
     * This color is closest to the start position.
     */
    var firstDayGradientStartColor : CGColor = CGColor.init(red: 0.933,
                                                       green: 0.424,
                                                       blue: 0.149,
                                                       alpha: 1.00) {
        willSet {
            self.clockSliderView?.viewModel.firstDayGradientStartColor = newValue
        }
    }
    
    /**
     * One of two colors which comprise the gradient used to fill the slider track.
     * The track uses this primary color scheme when the time span is between 0 and 12 hours.
     * This color is closest to the finish position.
     */
    @IBInspectable
    var firstDayGradientFinishColor : CGColor = CGColor.init(red: 0.965,
                                                        green: 0.965,
                                                        blue: 0.065,
                                                        alpha: 1.00) {
        willSet {
            self.clockSliderView?.viewModel.firstDayGradientFinishColor = newValue
        }
    }
    
    /**
     * One of two colors which comprise the gradient used to fill the slider track.
     * The track switches to this alternate color scheme when the time span is between 12 and 24 hours.
     * This color is closest to the start position.
     */
    @IBInspectable
    var secondDayGradientStartColor : CGColor = CGColor.init(red: 0.072,
                                                        green: 0.878,
                                                        blue: 0.087,
                                                        alpha: 1.00) {
        willSet {
            self.clockSliderView?.viewModel.secondDayGradientStartColor = newValue
        }
    }
    
    /**
     * One of two colors which comprise the gradient used to fill the slider track.
     * The track switches to this alternate color scheme when the time span is between 12 and 24 hours.
     * This color is closest to the finish position.
     */
    @IBInspectable
    var secondDayGradientFinishColor : CGColor = CGColor.init(red: 0.833,
                                                         green: 0.994,
                                                         blue: 0.342,
                                                         alpha: 1.00) {
        willSet {
            self.clockSliderView?.viewModel.secondDayGradientFinishColor = newValue
        }
    }
       
    //MARK:- initialization
    public init(_frame: CGRect,
                _ringWidth: CGFloat,
                _clockType: ClockType,
                _timeOfDay: TimeOfDayModel,
                _sliderStartTime: TimeOfDayModel,
                _sliderEndTime: TimeOfDayModel) {
        viewModel = TimeRangeSliderControlViewModel(frame: _frame,
                                                    ringWidth: _ringWidth,
                                                    clockType: _clockType,
                                                    timeOfDay: _timeOfDay,
                                                    sliderStartTime: _sliderStartTime,
                                                    sliderEndTime: _sliderEndTime)
        
        let clockRadius = self.viewModel.clockRadius
        clockFaceView = CrossPlatformClockFaceView(_frame: _frame,
                                                   _ringWidth: _ringWidth,
                                                   _viewModel: viewModel.clockFaceViewModel)
        startKnobView = CrossPlatformThumbnailView(_frame: _frame,
                                                   _ringWidth: _ringWidth,
                                                   _clockRadius: clockRadius)
        finishKnobView = CrossPlatformThumbnailView(_frame: _frame,
                                               _ringWidth: _ringWidth,
                                                    _clockRadius: clockRadius)
    }
    
    //MARK: - drawing
    public func draw(_ dirtyRect: CGRect, context: CGContext) {
        context.saveGState()
        context.setShouldAntialias(true)
        let clockRadius = self.viewModel.clockRadius
        
        // we want to do all the drawing using the center of the clock as the origin
        // to achieve this, translate the view
        context.translateBy(x: clockRadius, y: clockRadius)
        
        //
        // the running time in the middle of the clock face
        //
        //TODO: 2024-12-24 jcross - figure out if the labels which show the "elapsed" time need to be replaced with anything (e.g. working hours are from 9am-10pm)
//        self.updateElapsedTime()
        
        context.restoreGState()
        

    }
}
