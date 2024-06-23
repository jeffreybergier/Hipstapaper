//
//  Created by Jeffrey Bergier on 2022/12/29.
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

public struct DeleteWebsiteConfirmationError: CustomNSError {
    
    public typealias OnCompletion = @MainActor @Sendable (Website.Selection) -> Void
    static public let errorDomain = "com.saturdayapps.Hipstapaper.model"
    public var errorCode: Int { 1001 }
    
    public var id: Website.Selection
    public var onConfirmation: OnCompletion
    
    public init(_ id: Website.Selection,
                onConfirmation: @escaping OnCompletion)
    {
        self.id = id
        self.onConfirmation = onConfirmation
    }
}

public struct DeleteTagConfirmationError: CustomNSError {
    
    static public var errorDomain = "com.saturdayapps.Hipstapaper.model"
    public var errorCode: Int { 1002 }
    
    public var id: Tag.Selection
    public var onConfirmation: (Tag.Selection) -> Void
    
    public init(_ id: Tag.Selection,
                onConfirmation: @escaping (Tag.Selection) -> Void)
    {
        self.id = id
        self.onConfirmation = onConfirmation
    }
}
