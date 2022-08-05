//
//  Created by Jeffrey Bergier on 2022/08/05.
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
import V3Localize

extension CPError: UserFacingError {
    
    public var message: Umbrella.LocalizationKey {
        switch self {
        case .accountStatus:
            return Phrase.errorCloudAccount.rawValue
        case .sync:
            return Phrase.errorCloudSync.rawValue
        }
    }
    
    public var title: LocalizationKey { Noun.erroriCloud.rawValue }
    public var dismissTitle: LocalizationKey { Verb.dismiss.rawValue }
    public var isCritical: Bool { false }
    public var options: [Umbrella.RecoveryOption] { [] }
}
