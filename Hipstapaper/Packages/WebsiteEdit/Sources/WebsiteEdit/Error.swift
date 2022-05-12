//
//  Created by Jeffrey Bergier on 2020/12/06.
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
import Umbrella
import Localize

public enum Error: UserFacingError {
    case take(Swift.Error)
    case convertImage
    case size(Int)
    case userCancelled
    case sx_save
    case sx_process
}

extension Error: LocalizedError {
    public var message: LocalizationKey {
        switch self {
        case .take:
            return Phrase.errorScreenshot.key
        case .convertImage:
            return Phrase.errorConvertImage.key
        case .size:
            return Phrase.errorImageSize.key
        case .userCancelled:
            return Phrase.errorUserCancel.key
        case .sx_process:
            return Phrase.errorProcessURL.key
        case .sx_save:
            return Phrase.errorSaveWebsite.key
        }
    }
}

extension Error: Equatable {
    public static func == (lhs: Error, rhs: Error) -> Bool {
        lhs.message == rhs.message
    }
}
