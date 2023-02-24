//
//  Created by Jeffrey Bergier on 2022/08/03.
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

@propertyWrapper
public struct ShareList: DynamicProperty {
    
    public struct Value {
        public var title:              LocalizedString
        public var shareErrorSubtitle: LocalizedString

        public var done:   ActionLocalization
        public var multi:  ActionLocalization
        public var single: ActionLocalization
        public var copy:   ActionLocalization
        public var error:  ActionLocalization
        
        public var itemTitle: (String?) -> ActionLocalization
        public var errorTitle: (String?) -> ActionLocalization
        public var itemSubtitle: ([URL]) -> LocalizedString
        
        internal init(_ b: Bundle) {
            self.title              = b.localized(key: Noun.share.rawValue)
            self.shareErrorSubtitle = b.localized(key: Phrase.shareError.rawValue)
            
            self.done       = Action.doneGeneric.localized(b)
            self.multi      = Action.shareMulti.localized(b)
            self.single     = Action.shareSingle.localized(b)
            self.copy       = Action.copyToClipboard.localized(b)
            self.error      = Action.shareError.localized(b)
            
            self.itemTitle = {
                var output = Action.shareSingle.localized(b)
                output.title = $0 ?? b.localized(key: Noun.untitled.rawValue)
                return output
            }
            self.errorTitle = {
                var output = Action.shareError.localized(b)
                output.title = $0 ?? b.localized(key: Noun.untitled.rawValue)
                return output
            }
            self.itemSubtitle = {
                precondition($0.isEmpty == false)
                switch $0.count {
                case 1:
                    let url = $0.first!
                    return url.prettyValue ?? url.absoluteString
                default:
                    // TODO: improve to use strings dict
                    return String(describing: $0.count) + " " + "websites"
                }
            }
        }
    }
    
    @Environment(\.bundle) private var bundle

    public init() {}
    
    public var wrappedValue: Value {
        Value(self.bundle)
    }
    
    public func key(_ input: LocalizationKey) -> LocalizedString {
        self.bundle.localized(key: input)
    }
}
