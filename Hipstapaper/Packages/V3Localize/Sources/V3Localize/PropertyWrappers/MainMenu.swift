//
//  Created by Jeffrey Bergier on 2022/07/21.
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
public struct MainMenu: DynamicProperty {
    
    public struct Value {
        public var openInWindow:  (LocalizeBundle) -> ActionLocalization
        public var openExternal:  (LocalizeBundle) -> ActionLocalization
        public var archiveYes:    (LocalizeBundle) -> ActionLocalization
        public var archiveNo:     (LocalizeBundle) -> ActionLocalization
        public var share:         (LocalizeBundle) -> ActionLocalization
        public var tagApply:      (LocalizeBundle) -> ActionLocalization
        public var websiteAdd:    (LocalizeBundle) -> ActionLocalization
        public var tagAdd:        (LocalizeBundle) -> ActionLocalization
        public var websiteEdit:   (LocalizeBundle) -> ActionLocalization
        public var tagEdit:       (LocalizeBundle) -> ActionLocalization
        public var websiteDelete: (LocalizeBundle) -> ActionLocalization
        public var tagDelete:     (LocalizeBundle) -> ActionLocalization
        public var deselectAll:   (LocalizeBundle) -> ActionLocalization
        public var error:         (LocalizeBundle) -> ActionLocalization
        
        public init() {
            self.openInWindow  = { Action.openInWindow.localized($0) }
            self.openExternal  = { Action.openExternal.localized($0)  }
            self.archiveYes    = { Action.archiveYes.localized($0)    }
            self.archiveNo     = { Action.archiveNo.localized($0)     }
            self.share         = { Action.share.localized($0)         }
            self.tagApply      = { Action.tagApply.localized($0)      }
            self.websiteAdd    = { Action.addWebsite.localized($0)    }
            self.tagAdd        = { Action.addTag.localized($0)        }
            self.websiteEdit   = { Action.editWebsite.localized($0)   }
            self.tagEdit       = { Action.editTag.localized($0)       }
            self.websiteDelete = { Action.deleteWebsite.localized($0) }
            self.tagDelete     = { Action.deleteTag.localized($0)     }
            self.deselectAll   = { Action.deselectAll.localized($0)   }
            self.error         = { Action.errorsPresent.localized($0) }
        }
    }
        
    public init() {}
    
    public var wrappedValue: Value {
        Value()
    }
}
