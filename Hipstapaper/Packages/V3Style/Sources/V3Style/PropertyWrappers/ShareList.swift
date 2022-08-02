//
//  Created by Jeffrey Bergier on 2022/08/02.
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
public struct ShareList: DynamicProperty {
    
    public enum Icon {
        case single, multi, error
    }
    
    public init() {}
    
    public struct Value {
        
        public func shareLabel(icon: Icon,
                               @ViewBuilder title: () -> some View,
                               @ViewBuilder subtitle: () -> some View)
                               -> some View
        {
            return Label {
                VStack(alignment: .leading, spacing: 2) {
                    title()
                    subtitle()
                        .font(.caption)
                }
            } icon: {
                switch icon {
                case .single:
                    Image(systemName: "square.and.arrow.up")
                case .multi:
                    Image(systemName: "square.and.arrow.up.on.square")
                case .error:
                    Image(systemName: "square.and.arrow.up.trianglebadge.exclamationmark")
                }
            }
            .font(.body)
            .lineLimit(1)
            .if(icon == .error) {
                $0.tint(Color.gray)
                  .foregroundColor(Color.gray)
            }
        }
        
        public func shareLabel(icon: Icon,
                               @ViewBuilder title: () -> some View)
                               -> some View
        {
            self.shareLabel(icon: icon, title: title, subtitle: { EmptyView() })
        }
    }
    
    public var wrappedValue: Value {
        Value()
    }
}
