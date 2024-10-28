//
//  ClockSliderViewModel.swift
//  ClockSliderLibrary
//
//  Created by Jason Cross on 2024-10-28.
//

import QuartzCore

public struct ClockSliderViewModel {
    var ringWidth: CGFloat
    let clockType: ClockType
    private var numberOfHours: Int { self.clockType.rawValue }
    var rotationEachHour: CGFloat { CGFloat(CGFloat(2 * Double.pi) / CGFloat(clockType.rawValue)) }
    internal var sliderStartAngle: CGFloat
    internal var sliderEndAngle: CGFloat
    internal var clockDuration: Int = 0
    internal var clockRotationCount: ClockRotationCount
    var radiusClockCenterToSliderTrackCenter: CGFloat
    var clockRadius: CGFloat
    var halfSliderTrackWidth : CGFloat
    var centerSliderTrackRadiusSquared: CGFloat
    var firstDayGradientStartColor : CGColor = CGColor.init(red: 0.933,
                                                       green: 0.424,
                                                       blue: 0.149,
                                                       alpha: 1.00) {
        didSet {
            self.breakStartAndFinishColorsIntoComponents()
        }
    }
    var firstDayGradientFinishColor : CGColor = CGColor.init(red: 0.965,
                                                        green: 0.965,
                                                        blue: 0.065,
                                                        alpha: 1.00) {
        didSet {
            self.breakStartAndFinishColorsIntoComponents()
        }
    }
    var secondDayGradientStartColor : CGColor = CGColor.init(red: 0.072,
                                                        green: 0.878,
                                                        blue: 0.087,
                                                        alpha: 1.00) {
        didSet {
            self.breakStartAndFinishColorsIntoComponents()
        }
    }
    var secondDayGradientFinishColor : CGColor = CGColor.init(red: 0.833,
                                                         green: 0.994,
                                                         blue: 0.342,
                                                         alpha: 1.00) {
        didSet {
            self.breakStartAndFinishColorsIntoComponents()
        }
    }
    internal var firstDayStartRed: CGFloat = 0
    internal var firstDayStartGreen: CGFloat = 0
    internal var firstDayStartBlue: CGFloat = 0
    internal var firstDayStartAlpha: CGFloat = 0
    internal var firstDayEndRed:  CGFloat = 0
    internal var firstDayEndGreen:  CGFloat = 0
    internal var firstDayEndBlue: CGFloat = 0
    internal var firstDayEndAlpha: CGFloat = 0
    internal var secondDayStartRed: CGFloat = 0
    internal var secondDayStartGreen: CGFloat = 0
    internal var secondDayStartBlue: CGFloat = 0
    internal var secondDayStartAlpha: CGFloat = 0
    internal var secondDayEndRed:  CGFloat = 0
    internal var secondDayEndGreen:  CGFloat = 0
    internal var secondDayEndBlue: CGFloat = 0
    internal var secondDayEndAlpha: CGFloat = 0
    internal let screenScale: CGFloat
    internal let angleEquivalentToOnePixel: CGFloat = CGFloat(Double.pi / 360.0)
    internal let thresholdForAdjustingArcRaduis = 2
    
    public init(_frame: CGRect,
         _clockType: ClockType,
         _ringWidth: CGFloat,
         _sliderStartAngle: CGFloat,
         _sliderEndAngle: CGFloat,
         _clockRotationCount: ClockRotationCount,
         _screenScale: CGFloat) {
        clockType = _clockType
        ringWidth = _ringWidth
        halfSliderTrackWidth = (ringWidth / 2.0)
        screenScale = _screenScale
        let diameter = CGFloat(fminf(Float(_frame.size.width),
                                     Float(_frame.size.height)))
        clockRadius = diameter / 2.0
        
        // uses the fact that lines are stroked half on each side of the line
        radiusClockCenterToSliderTrackCenter = clockRadius - halfSliderTrackWidth
        centerSliderTrackRadiusSquared = (radiusClockCenterToSliderTrackCenter * radiusClockCenterToSliderTrackCenter)
        sliderStartAngle = _sliderStartAngle
        sliderEndAngle = _sliderEndAngle
        clockRotationCount = _clockRotationCount
        
        self.breakStartAndFinishColorsIntoComponents()
    }
    
    mutating func setClock(startAngle: CGFloat,
                  finishAngle: CGFloat,
                  clockDuration: Int,
                  rotationCount: ClockRotationCount) {
        self.sliderStartAngle = startAngle
        self.sliderEndAngle = finishAngle
        self.clockDuration = clockDuration
        self.clockRotationCount = rotationCount
    }
    
    fileprivate mutating func breakStartAndFinishColorsIntoComponents() -> Void {
        self.firstDayGradientStartColor.getRed(&firstDayStartRed,
                                               green: &firstDayStartGreen,
                                               blue: &firstDayStartBlue,
                                               alpha: &firstDayStartAlpha)
        
        self.firstDayGradientFinishColor.getRed(&firstDayEndRed,
                                                green: &firstDayEndGreen,
                                                blue: &firstDayEndBlue,
                                                alpha: &firstDayEndAlpha)
        
        self.secondDayGradientStartColor.getRed(&secondDayStartRed,
                                                green: &secondDayStartGreen,
                                                blue: &secondDayStartBlue,
                                                alpha: &secondDayStartAlpha)
        
        self.secondDayGradientFinishColor.getRed(&secondDayEndRed,
                                                 green: &secondDayEndGreen,
                                                 blue: &secondDayEndBlue,
                                                 alpha: &secondDayEndAlpha)
    }
    
    func thumbnailCenterPoint(_ minutes: CGFloat) -> CGPoint {
        var value = CGPoint.zero
        
        //                      opposite
        //                    |---------
        //                    |        /
        //                    |       /
        //           adjacent |      /
        //                    |     /  hypoteneuse
        //                    |    /
        //                    | O /
        //                    |  /
        //                    | /
        //                    |/
        //
        // Picture a clock face, with 12 o'clock in the expected north position.
        // In iOS, any arc drawing is done starting from the X-plane, which would be at 3 o'clock.
        // To compensate for this, start all arc drawing from 1/4 turn counter-clockwise: - Pi/2.
        // Therefore picture one line segment heading directly north, to 12 o'clock.
        // The second line segment will where the hour hand would be at 1 o'clock.
        // The angle is between these two lines
        let angle = self.clockFaceAngle(screenMinutes: minutes)
        
        // We know the length of the line segment from the center of the clock to the 1 o'clock position
        let hypoteneuse = radiusClockCenterToSliderTrackCenter
        
        // Now draw a line from the center of the "ring", or the 1 o'clock position,
        // horizontally straight across (to the left), which will intersect the 12 o'clock line
        var opposite: CGFloat
        
        // Now use geometry to solve for the opposite length
        // using this formula: sin(theta) = oposite / hypoteneuse
        // which gives: opposite = sin(theta) * hypoteneuse
        opposite = sin(angle) * hypoteneuse
        
        // likewise the adjacent may be found
        // using the formula: cos(theta) = adjacent / hypoteneuse
        let adjacent: CGFloat = cos(angle) * hypoteneuse
        
        // Remember that the X-axis runs from the center of the clock to the 3 o'clock position
        // And the Y-axis runs between 6 o'clock and 12 o'clock, but running up is negative.
        // Also remember that our drawRect uses a translated coordinate system;
        // without translation, the origin would be in the upper left corder
        value = CGPoint(x: opposite + clockRadius,
                        y: -adjacent + clockRadius)
        return value
    }
    
    /**
     provides mapping between the position on the clock of the *hour* hand (in minutes),
     and the angle of the *hour* hand from 12 o'clock
     
     - parameter screenMinutes: the number of minutes the hour hand has moved from 12 o'clock position
     
     - returns: clockFaceAngle the angle between the vertical (running to 12) and the current hour hand
     */
    func clockFaceAngle(screenMinutes minutes: CGFloat) -> CGFloat {
        let ticksPerRevolution: Int = self.numberOfHours * 60
        let numberOfTicks = minutes.truncatingRemainder(dividingBy: CGFloat(ticksPerRevolution))
        let value = (CGFloat(numberOfTicks) / CGFloat(ticksPerRevolution)) * CGFloat(2 * Double.pi)
        return value
    }
    
    /**
     rounds the minutes passed in, such that the returned result is an even multiple
     of the increment duration.
     
     - example: round(74) where increment_duration is 15, returns 75
     
     - parameter minutes: the minutes which need to be rounded
     
     - returns: the rounded minutes
     */
    fileprivate static func roundMinutesToMatchIncrementDuration(_ minutes: CGFloat, incrementDuration: Int) -> Int {
        let remainder: CGFloat = minutes.truncatingRemainder(dividingBy: CGFloat(incrementDuration))
        let floor: Int = Int(round(minutes - remainder))
        let roundedRemainder: Int = Int(round(remainder / CGFloat(incrementDuration)) * CGFloat(incrementDuration))
        let roundedMinutes: Int = roundedRemainder + floor
        return roundedMinutes
    }
}
