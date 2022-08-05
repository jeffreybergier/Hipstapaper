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
import CloudKit
import Umbrella

// TODO: extension CPError: UserFacingError {}

extension CPError {
    public var codableValue: CodableError {
        switch self {
        case .accountStatus(let status):
            let data = try? PropertyListEncoder().encode(status.rawValue)
            return CodableError(domain: type(of: self).errorDomain,
                                code: self.errorCode,
                                arbitraryData: data)
        case .sync(let error):
            // TODO: Enhance to save suberror kind
            NSLog(String(describing: error))
            return CodableError(self)
        }
    }
    
    public init?(codableError: CodableError) {
        guard type(of: self).errorDomain == codableError.errorDomain else { return nil }
        switch codableError.errorCode {
        case 1001:
            let status: CPAccountStatus = {
                guard
                    let data = codableError.arbitraryData,
                    let rawValue = try? PropertyListDecoder().decode(Int.self, from: data),
                    let status = CPAccountStatus(rawValue: rawValue)
                else { return .couldNotDetermine }
                return status
            }()
            self = .accountStatus(status)
        case 1002:
            self = .sync(nil)
        default:
            return nil
        }
    }
}
