//
//  Created by Jeffrey Bergier on 2022/07/01.
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

@propertyWrapper
public struct WebsiteEdit: DynamicProperty {
    
    public init() {}
    
    public struct Value {
        public var stop            = Action.browseStop
        public var jsYes           = Action.javascriptYes
        public var jsNo            = Action.javascriptNo
        public var autofill        = Action.autofill
        public var deleteThumbnail = Action.deleteThumbnail
        public var deleteWebsite   = Action.genericDelete
        public var done            = Action.genericDone
        public var empty           = Action.noContent
        public var tabWebsite      = Action.websiteGeneric
        public var tabTag          = Action.tagGeneric
        public var error           = Action.errorPresent
        
        public func thumbnailSingle(_ data: Data?, @ViewBuilder background: @escaping () -> some View) -> some View {
            WebThumbnailImage(data, web: background)
                .frame(width: .thumbnailLarge, height: .thumbnailLarge)
                .cornerRadius(.cornerRadiusMedium)
        }
        public func thumbnailMulti(_ data: Data?) -> some View {
            ThumbnailImage(data)
                .frame(width: .thumbnailMedium, height: .thumbnailMedium)
                .cornerRadius(.cornerRadiusSmall)
        }
    }
    
    public var wrappedValue: Value {
        Value()
    }
}
