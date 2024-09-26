//
//  Created by Jeffrey Bergier on 2022/07/30.
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

@MainActor
@propertyWrapper
public struct DetailTable: DynamicProperty {
    
    @MainActor
    public struct Value {
        public var date:      some ViewModifier = DetailTableDateText()
        public var url:       some ViewModifier = DetailTableURLText()
        public var title:     some ViewModifier = DetailTableTitleText()
        public var hack_edit: some ActionStyle  = ActionStyleImp(labelStyle: .titleOnly)
        public var hack_done: some ActionStyle  = JSBToolbarButtonStyleDone
        
        public var columnWidthDate:      CGFloat = .dateColumnWidthMax
        public var columnWidthThumbnail: CGFloat = .thumbnailColumnWidth
        
        public func thumbnail(_ data: Data?) -> some View {
            ThumbnailImage(data)
                .frame(width: .thumbnailSmall, height: .thumbnailSmall)
                .cornerRadius(.cornerRadiusSmall)
        }
        public func syncIndicator(_ progress: Progress) -> some ViewModifier {
            SyncIndicator(progress)
        }
    }
        
    public init() {}
    
    public var wrappedValue: Value {
        Value()
    }
}
