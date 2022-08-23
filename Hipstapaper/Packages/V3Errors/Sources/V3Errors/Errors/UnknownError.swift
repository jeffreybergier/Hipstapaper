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

import Umbrella
import V3Localize

internal struct UnknownError: UserFacingError {
    internal var title: Umbrella.LocalizationKey        = Noun.error.rawValue
    internal var message: Umbrella.LocalizationKey      = Phrase.errorUnknown.rawValue
    internal var dismissTitle: Umbrella.LocalizationKey = Verb.dismiss.rawValue
    internal var isCritical: Bool { false }
    internal var options: [Umbrella.RecoveryOption]     = []
    
    internal init(_ error: CodableError) {
        self.errorCode = error.errorCode
        self.errorDomain = error.errorDomain
        guard
            let data = error.arbitraryData,
            let userInfoString = String(data: data, encoding: .utf8)
        else { return }
        self.message = userInfoString
    }
    
    internal static var errorDomain: String { "com.saturdayapps.Hipstapaper.Unknown" }
    internal var errorDomain: String
    internal var errorCode: Int
}
