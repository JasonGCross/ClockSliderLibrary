//
//  ClockFaceViewModelTests.swift
//  ClockSliderLibrary
//
//  Created by Jason Cross on 2024-10-28.
//

import QuartzCore
import CoreText
import Testing
@testable import ClockSliderLibrary

struct ClockFaceViewModelTests {
    
    @Test func validateGettingGlyphsFromString() throws {
        let font = CTFontCreateWithName("ArialMT" as CFString, 14.0, nil)
        let string = "Hello there"
        let pixelsWide = 100
        let pixelsHigh = 100
        let bitmapBytesPerRow =  (pixelsWide * 4)
        let bitmapInfo: UInt32 = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        
        let context = CGContext(data: nil,
                                width: pixelsWide,
                                height: pixelsHigh,
                                bitsPerComponent: 8,
                                bytesPerRow: bitmapBytesPerRow,
                                space: CGColorSpaceCreateDeviceRGB(),
                                bitmapInfo: bitmapInfo)
        try #require(nil != context)
        let glyphs = ClockFaceViewModel.getGlyphsFromString(string, usingFont: font, context: context!)
        #expect(glyphs.count > 0)
    }
}
