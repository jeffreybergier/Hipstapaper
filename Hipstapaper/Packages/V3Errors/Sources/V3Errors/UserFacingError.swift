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
import V3Model

extension CodableError {
    internal func userFacingError(onConfirm: OnConfirmation? = nil) -> UserFacingError {
        let knownError: UserFacingError? = {
            switch self.errorDomain {
            case DeleteWebsiteError.errorDomain:
                return DeleteWebsiteError(self, onConfirm: onConfirm)
            case DeleteTagError.errorDomain:
                return DeleteTagError(self, onConfirm: onConfirm)
            default:
                return nil
            }
        }()
        return knownError ?? UnknownError(self)
    }
}

// MARK: DeleteTagError

extension DeleteTagError {
    internal init?(_ error: CodableError, onConfirm: OnConfirmation?) {
        guard
            error.errorDomain == type(of: self).errorDomain,
            error.errorCode == self.errorCode,
            let data = error.arbitraryData,
            let identifiers = try? PropertyListDecoder().decode(Tag.Selection.self, from: data)
        else { return nil }
        self.identifiers = identifiers
        self.onConfirm = onConfirm
    }
    
    public var codableValue: CodableError {
        var error = CodableError(self as NSError)
        error.arbitraryData = try? PropertyListEncoder().encode(self.identifiers)
        return error
    }
}

// MARK: DeleteWebsiteError

extension DeleteWebsiteError {
    internal init?(_ error: CodableError, onConfirm: OnConfirmation?) {
        guard
            error.errorDomain == type(of: self).errorDomain,
            error.errorCode == self.errorCode,
            let data = error.arbitraryData,
            let identifiers = try? PropertyListDecoder().decode(Website.Selection.self, from: data)
        else { return nil }
        self.identifiers = identifiers
        self.onConfirm = onConfirm
    }
    
    public var codableValue: CodableError {
        var error = CodableError(self as NSError)
        error.arbitraryData = try? PropertyListEncoder().encode(self.identifiers)
        return error
    }
}
