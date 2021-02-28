//
//  Created by Jeffrey Bergier on 2021/02/06.
//
//  MIT License
//
//  Copyright (c) 2021 jeffreybergier
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
import Stylize
import Datum
import Localize

enum DeleteError: UserFacingError {
    
    typealias OnConfirmation = () -> Void
    
    case website(OnConfirmation)
    case tag(OnConfirmation)
    
    var title: LocalizedStringKey {
        switch self {
        case .tag:
            return Noun.deleteTag.rawValue
        case .website:
            return Noun.deleteWebsite.rawValue
        }
    }
    var message: LocalizedStringKey {
        switch self {
        case .tag:
            return Phrase.deleteTagConfirm.rawValue
        case .website:
            return Phrase.deleteWebsiteConfirm.rawValue
        }
    }
    var options: [RecoveryOption] {
        switch self {
        case .tag(let onConfirm):
            return [.init(title: Verb.deleteTag.rawValue, isDestructive: true, perform: onConfirm)]
        case .website(let onConfirm):
            return [.init(title: Verb.deleteWebsite.rawValue, isDestructive: true, perform: onConfirm)]
        }
    }
    
    var errorCode: Int {
        switch self {
        case .tag:
            return 1001
        case .website:
            return 1002
        }
    }
}

