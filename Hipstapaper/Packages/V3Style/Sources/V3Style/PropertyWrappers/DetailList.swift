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

@propertyWrapper
public struct DetailList: DynamicProperty {
        
    public struct Value {
        public var dateLineLimit: LineLimit
        public var urlLineLimit: LineLimit
        public var titleLineLimit: LineLimit
        public func thumbnail(_ data: Data?) -> some View {
            ThumbnailImage(data)
                .frame(width: .thumbnailSmall, height: .thumbnailSmall)
                .cornerRadius(.cornerRadiusSmall)
        }
    }
    
    @Environment(\.dynamicTypeSize) private var typeSize
    
    public init() {}
    
    public var wrappedValue: Value {
        let isA = self.typeSize.isAccessibilitySize
        return Value(dateLineLimit: .init(limit: isA ? 2 : 1, reserve: true),
                     urlLineLimit: .init(limit: isA ? 2 : 1, reserve: true),
                     titleLineLimit: .init(limit: isA ? 4 : 2, reserve: true))
    }
}
