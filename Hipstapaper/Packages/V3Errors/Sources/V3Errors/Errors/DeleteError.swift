//
//  Created by Jeffrey Bergier on 2022/07/18.
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
import V3Localize

public struct DeleteTagError: UserFacingError, CustomNSError {
    
    public var identifiers: Tag.Selection = []
    internal var onConfirm: OnConfirmation?
    
    public init(_ identifiers: Tag.Selection) {
        self.identifiers = identifiers
    }
        
    // MARK: Protocol conformance
    public static var errorDomain: String = "com.saturdayapps.Hipstapaper.Delete.Tag"
    public var errorCode: Int = 1001
    public var title: LocalizationKey = Noun.deleteTag.rawValue
    public var message: LocalizationKey = Phrase.deleteTagConfirm.rawValue
    public var dismissTitle: LocalizationKey = Verb.dontDelete.rawValue
    public var isCritical: Bool = false
    public var options: [RecoveryOption] {
        return [
            .init(title: Verb.deleteTag.rawValue, isDestructive: true) {
                self.onConfirm?(.deleteTags(self.identifiers))
            }
        ]
    }
}

public struct DeleteWebsiteError: UserFacingError, CustomNSError {
    
    public var identifiers: Website.Selection = []
    internal var onConfirm: OnConfirmation?
    
    public init(_ identifiers: Website.Selection) {
        self.identifiers = identifiers
    }
        
    // MARK: Protocol conformance
    public static var errorDomain: String = "com.saturdayapps.Hipstapaper.Delete.Website"
    public var errorCode: Int = 1001
    public var title: LocalizationKey = Noun.deleteWebsite.rawValue
    public var message: LocalizationKey = Phrase.deleteWebsiteConfirm.rawValue
    public var dismissTitle: LocalizationKey = Verb.dontDelete.rawValue
    public var isCritical: Bool = false
    public var options: [RecoveryOption] {
        return [
            .init(title: Verb.deleteWebsite.rawValue, isDestructive: true) {
                self.onConfirm?(.deleteWebsites(self.identifiers))
            }
        ]
    }
}
