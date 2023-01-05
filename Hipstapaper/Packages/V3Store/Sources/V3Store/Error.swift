//
//  Created by Jeffrey Bergier on 2020/11/24.
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

/// Programming errors like not being able to load MOM from bundle
/// and updating values from different Context cause fatalError
/// rather than throwing an error.
public enum Error: Int, CustomNSError {
    /// When an error is returned from `NSPersistentContainter` during inital setup.
    case initialize = 1001
    /// When NSManagedContext return an error while `saveContext()`.
    case write = 1002
    /// When NSManagedContext return an error while `performFetch()`.
    case read = 1003

    public static let errorDomain: String = "com.saturdayapps.Hipstapaper.V3Store"
    
    public var errorCode: Int { self.rawValue }
}

extension Error: CodableErrorConvertible {
    public init?(decode: CodableError) {
        guard decode.errorDomain == Error.errorDomain else { return nil }
        self.init(rawValue: decode.errorCode)
    }
    public var encode: CodableError {
        .init(self)
    }
}
