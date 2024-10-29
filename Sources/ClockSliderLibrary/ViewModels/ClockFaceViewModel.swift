//
//  ClockFaceViewModel.swift
//  ClockSliderLibrary
//
//  Created by Jason Cross on 2024-10-28.
//

import Foundation
import CoreText

enum ClockFaceViewModelError: Error {
    case cannotGetGlyphs
}

public struct ClockFaceViewModel {
    var clockType: ClockType = .twelveHourClock
    var numberOfHours: Int { self.clockType.rawValue }
    var rotationEachHour: CGFloat { CGFloat(CGFloat(2 * Double.pi) / CGFloat(clockType.rawValue)) }
    var clockTime = TimeOfDayModel.now
    
    internal static func getGlyphsFromString(_ textString: String,
                                             usingFont coreTextFont: CTFont,
                                             context: CGContext) -> [CGGlyph] {
        
        let uniChar : [UniChar] = textString.utf16.map { scalar in
            UniChar(scalar)
        }
        var glyphs: [CGGlyph] = [CGGlyph](repeating: 0, count: uniChar.count)
        guard CTFontGetGlyphsForCharacters(coreTextFont, uniChar, &glyphs, uniChar.count) else {
            return glyphs
        }
        return glyphs
    }
}
