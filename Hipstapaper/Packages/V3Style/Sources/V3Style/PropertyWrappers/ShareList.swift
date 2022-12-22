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
import Umbrella

@propertyWrapper
public struct ShareList: DynamicProperty {
    
    public struct Value {
        
        public var popoverSize: some ViewModifier = PopoverSize(size: .medium)
        
        public func disabled(subtitle: String) -> some ActionStyle {
            ActionStyleImp(outerModifier: ModifierDisabledFake(),
                           innerModifier: ModifierSubtitle(subtitle: subtitle))
        }
        
        public func shareLink(itemURLs: [URL],
                              itemTitle: ActionLocalization,
                              itemSubtitle: LocalizedString,
                              copyTitle: ActionLocalization? = nil,
                              copyAction: (() -> Void)? = nil)
                              -> some View
        {
            ShareLink(items: itemURLs) {
                HStack {
                    self.enabled(subtitle: itemSubtitle)
                        .action(text: itemTitle)
                        .label
                    copyTitle.view { copyTitle in
                        Spacer()
                        self.copy
                            .action(text: copyTitle)
                            .button(item: copyAction, action: { $0() })
                    }
                }
            }
        }
        
        private var copy: some ActionStyle = ActionStyleImp(
            labelStyle: .iconOnly,
            outerModifier: ModifierButtonStyle(style: .bordered)
        )
        private func enabled(subtitle: String) -> some ActionStyle {
            ActionStyleImp(innerModifier: ModifierSubtitle(subtitle: subtitle))
        }
    }
    
    public init() {}
    
    public var wrappedValue: Value {
        Value()
    }
}

fileprivate struct ModifierSubtitle: ViewModifier {
    private let subtitle: String
    fileprivate init(subtitle: String) {
        self.subtitle = subtitle
    }
    fileprivate func body(content: Content) -> some View {
        VStack(alignment: .leading, spacing: .labelVSpacingSmall) {
            content
                .truncationMode(.tail)
            Text(self.subtitle)
                .font(.small)
                .truncationMode(.middle)
        }
        .lineLimit(1)
    }
}
