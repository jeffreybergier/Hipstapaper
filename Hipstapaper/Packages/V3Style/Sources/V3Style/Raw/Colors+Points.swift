//
//  Created by Jeffrey Bergier on 2022/07/06.
//
//  MIT License
//
//  Copyright (c) 2021 Jeffrey Bergier
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import SwiftUI

extension TimeInterval {
    internal static let syncIndicatorTimer: TimeInterval = 3
}

extension Font {
    internal static let syncIndicatorIcon: Font = .title
    internal static let prominent: Font = .headline
    internal static let normal: Font = .body
    internal static let small: Font = .caption
}

extension CGFloat {
    internal static let popoverSizeWidthSmall: CGFloat = 240
    internal static let popoverSizeWidthMedium: CGFloat = 320
    internal static let popoverSizeWidthLarge: CGFloat = 480
    internal static let popoverSizeHeightSmall: CGFloat = 320
    internal static let popoverSizeHeightMedium: CGFloat = 480
    internal static let popoverSizeHeightLarge: CGFloat = 720
    internal static let labelVSpacing: CGFloat = 2
    internal static let syncOvalPaddingTopHidden: CGFloat = -64
    internal static let syncOvalPaddingTopShown: CGFloat = 8
    internal static let ovalWidthMinimum: CGFloat = 28
    internal static let paddingOvalHorizontal: CGFloat = 8
    internal static let paddingOvalVertical: CGFloat = 4
    internal static let cornerRadiusMedium: CGFloat = 8
    internal static let cornerRadiusSmall: CGFloat = 4
    internal static let dateColumnWidthMax: CGFloat = 8*14
    internal static let thumbnailColumnWidth: CGFloat = .thumbnailSmall + 4
    internal static let thumbnailSmall: CGFloat = 64
    internal static let thumbnailMedium: CGFloat = 128
    /// set based on iPhone 12 mini zoomed mode
    internal static let thumbnailLarge: CGFloat = 280
}

extension Color {
    internal static func grayLight(_ scheme: ColorScheme) -> Color {
        scheme.isLight ? Color(red: 0.9, green: 0.9, blue: 0.9)
                       : Color(red: 0.25, green: 0.25, blue: 0.25)
    }
    internal static func grayMedium(_ scheme: ColorScheme) -> Color {
        scheme.isLight ? Color(red: 0.8, green: 0.8, blue: 0.8)
                       : Color(red: 0.35, green: 0.35, blue: 0.35)
    }
    internal static func grayDark(_ scheme: ColorScheme) -> Color {
        scheme.isLight ? Color(red: 0.7, green: 0.7, blue: 0.7)
                       : Color(red: 0.25, green: 0.25, blue: 0.25)
    }
    internal static func text(_ scheme: ColorScheme) -> Color {
        scheme.isLight ? Color.black
                       : Color.white
    }
}

extension ColorScheme {
    fileprivate var isLight: Bool {
        switch self {
        case .dark:
            return false
        case .light:
            fallthrough
        @unknown default:
            return true
        }
    }
}
