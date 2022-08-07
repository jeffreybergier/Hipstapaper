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
        
        public var popoverSize: some ViewModifier = PopoverSize(size: .medium)
        
        public func copyButton(action: @escaping () -> Void) -> some View {
            return Action.copy.button("", style: .icon, action: action)
                         .buttonStyle(.bordered)
        }
        
        public func shareLabel(icon: Icon,
                               @ViewBuilder title: () -> some View,
                               @ViewBuilder subtitle: () -> some View,
                               @ViewBuilder accessory: () -> some View)
                               -> some View
        {
            return Label {
                HStack {
                    VStack(alignment: .leading, spacing: .labelVSpacingSmall) {
                        title()
                        subtitle()
                            .font(.small)
                    }
                    accessory()
                }
            } icon: {
                switch icon {
                case .single:
                    Image(systemName: SystemImage.share.rawValue)
                case .multi:
                    Image(systemName: SystemImage.shareMulti.rawValue)
                case .error:
                    Image(systemName: SystemImage.shareError.rawValue)
                }
            }
            .font(.normal)
            .lineLimit(1)
            .if(icon == .error) {
                $0.modifier(FakeDisable())
            }
        }
    }
    
    public var wrappedValue: Value {
        Value()
    }
}

extension ShareList.Value {
    public func shareLabel(icon: ShareList.Icon,
                           @ViewBuilder title: () -> some View)
                           -> some View
    {
        self.shareLabel(icon: icon,
                        title: title,
                        subtitle: { EmptyView() },
                        accessory: { EmptyView() })
    }
    
    public func shareLabel(icon: ShareList.Icon,
                           @ViewBuilder title: () -> some View,
                           @ViewBuilder subtitle: () -> some View)
                           -> some View
    {
        self.shareLabel(icon: icon,
                        title: title,
                        subtitle: subtitle,
                        accessory: { EmptyView() })
    }
}
