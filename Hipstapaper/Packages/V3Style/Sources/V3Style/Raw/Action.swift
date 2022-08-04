//
//  Created by Jeffrey Bergier on 2022/06/17.
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

public typealias AC = Action.Closure

public struct Action {
    
    public enum Style {
        case automatic, label, icon, title
    }
    
    public typealias Closure = () -> Void
    public var systemImage: String
    public var shortcut: KeyboardShortcut?
}

extension Action {
    public func button<T>(_ titleKey: LocalizedString,
                       style: Style = .automatic,
                       role: ButtonRole? = nil,
                       enabled: T? = nil,
                       action: @escaping (T) -> Void) -> some View
    {
        Button(role: role) {
            guard let enabled else { return }
            action(enabled)
        } label: {
            self.label(titleKey, style: style)
        }
        .keyboardShortcut(self.shortcut)
        .disabled(enabled == nil)
    }
    
    public func button<C: Collection>(_ titleKey: LocalizedString,
                       style: Style = .automatic,
                       role: ButtonRole? = nil,
                       enabled: C = [],
                       action: @escaping (C) -> Void) -> some View
    {
        Button(role: role) {
            action(enabled)
        } label: {
            self.label(titleKey, style: style)
        }
        .keyboardShortcut(self.shortcut)
        .disabled(enabled.isEmpty)
    }
    
    public func button(_ titleKey: LocalizedString,
                       style: Style = .automatic,
                       role: ButtonRole? = nil,
                       enabled: Bool = true,
                       action: @escaping Closure) -> some View
    {
        Button(role: role, action: action) {
            self.label(titleKey, style: style)
        }
        .keyboardShortcut(self.shortcut)
        .disabled(!enabled)
    }
    
    public func label(_ titleKey: LocalizedString,
                      style: Style = .automatic) -> some View
    {
        Label(titleKey, systemImage: self.systemImage)
            .modifier(LabelStyler(style))
    }
}

fileprivate struct LabelStyler: ViewModifier {
    private let style: Action.Style
    init(_ style: Action.Style) {
        self.style = style
    }
    func body(content: Content) -> some View {
        switch style {
        case .automatic:
            content.labelStyle(.automatic)
        case .label:
            content.labelStyle(.titleAndIcon)
        case .icon:
            content.labelStyle(.iconOnly)
        case .title:
            content.labelStyle(.titleOnly)
        }
    }
}
