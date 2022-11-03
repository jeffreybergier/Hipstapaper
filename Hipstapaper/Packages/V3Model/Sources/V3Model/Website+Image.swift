//
//  Created by Jeffrey Bergier on 2022/07/10.
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

import Foundation
import Umbrella
#if canImport(AppKit)
import AppKit
#else
import UIKit
#endif

extension Website {
    
    public static let maxSize = 100_000
    internal static let compression = 2...10
    
    public mutating func setThumbnail(_ newValue: JSBImage) {
        self.thumbnail = type(of: self).compress(image: newValue)
    }
    
    #if os(macOS)
    private static func compress( image: JSBImage) -> Data? {
        for denominator in self.compression {
            let compression: Float = 1 / Float(denominator)
            guard
                let tiff = image.tiffRepresentation,
                let rep = NSBitmapImageRep(data: tiff),
                let data = rep.representation(using: NSBitmapImageRep.FileType.jpeg,
                                              properties: [.compressionFactor: compression]),
                data.count <= self.maxSize
            else { continue }
            return data
        }
        return nil
    }
    #else
    private static func compress( image: JSBImage) -> Data? {
        for denominator in self.compression {
            let compression: CGFloat = 1 / CGFloat(denominator)
            guard
                let data = image.jpegData(compressionQuality: compression),
                data.count <= self.maxSize
            else { continue }
            return data
        }
        return nil
    }
    #endif
}
