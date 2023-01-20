//
//  Created by Jeffrey Bergier on 2022/06/29.
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

/// Attempts to use `localized` properties on `NSError`.
/// If the NSError has recovery options, presents them to the user and attempts recovery.
/// If no options, attempts to piece together a reasonable error for the user.
public struct LocalizedNSError: UserFacingError {
    
    public static var errorDomain: String { "com.saturdayapps.Hipstapaper.LocalizedNSError" }
    public var errorDomain: String
    public var errorCode: Int
    
    public var title:   LocalizationKey
    public var message: LocalizationKey
    public var options: [RecoveryOption]
    public var dismissTitle: LocalizationKey
    
    public var isCritical: Bool { false }
    
    public init(_ error: any Swift.Error, dismissTitle: LocalizationKey) {
        let error = error as NSError
        self.errorCode = error.code
        self.errorDomain = error.domain
        self.dismissTitle = dismissTitle
        if let suggestion = error.localizedRecoverySuggestion {
            self.title = error.localizedDescription
            self.message = suggestion
            self.options = (error.localizedRecoveryOptions ?? []).enumerated().map
            { index, title in
                .init(title: title) {
                    NSError.attemptRecovery(fromError: error, optionIndex: index)
                }
            }
        } else {
            self.title   = error.domain
            self.message = error.localizedDescription
            self.options = []
        }
    }
}
