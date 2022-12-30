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

import Umbrella
import V3Errors
import V3Model

// TODO: Errors, yuck. So much to do
// MARK: Is it possible for this to live elsewhere?
public enum ErrorRouter {
    public static let route: (CodableError) -> any UserFacingError = { input in
        var output: UserFacingError?
        switch input.errorDomain {
        // case CPError.errorDomain:
            // output = CPError(codableError: input)
        case DeleteRequestError.errorDomain:
            output = DeleteRequestError(decode: input).map {
                DeleteConfirmationError(request: $0) {
                    switch $0 {
                    case .website(let selection):
                        break
                    case .tag(let selection):
                        break
                    }
                }
            }
        default:
            break
        }
        return output ?? UnknownError(input)
    }
}

// TODO: Errors, yuck. So much to do
extension DeleteConfirmationError: UserFacingError {
    public var title: Umbrella.LocalizationKey {
        ""
    }
    
    public var message: Umbrella.LocalizationKey {
        "Delete?"
    }
    
    public var dismissTitle: Umbrella.LocalizationKey {
        "Dooooooooonnnnnt Del"
    }
    
    public var isCritical: Bool {
        false
    }
    
    public var options: [Umbrella.RecoveryOption] {
        []
    }
}
