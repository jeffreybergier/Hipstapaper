//
//  Created by Jeffrey Bergier on 2021/02/23.
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
import Localize

public protocol Labelable {
    /// Icon in label or toolbar
    static var icon: STZ.ICN? { get }
    /// Action / Title / Label / Button Text
    static var verb: Verb { get }
}

public protocol Buttonable: Labelable {
    /// Tooltip / Accessibility
    static var phrase: Phrase { get }
    /// Keyboard shortcut
    static var shortcut: KeyboardShortcut? { get }
}

public typealias Toolbarable = Buttonable

public protocol Presentable: Buttonable {
    /// Title of presented view
    static var noun: Noun { get }
}

extension Labelable {
    // TODO: Remove AnyView. For some reason, it is failing to build when using `some View`
    public static func label() -> AnyView {
        if let icon = self.icon {
            return AnyView(
                Label(self.verb.rawValue, systemImage: icon.rawValue)
                    .modifier(STZ.FNT.Sort.apply())
            )
        } else {
            return AnyView(
                STZ.VIEW.TXT(self.verb.rawValue)
                    .modifier(STZ.FNT.Sort.apply())
            )
        }
    }
}

extension Buttonable {
    public static func button(doneStyle: Bool = false,
                              isEnabled: Bool = true,
                              action: @escaping Action)
                              -> some View
    {
        self.context(doneStyle: doneStyle,
                     isEnabled: isEnabled,
                     action: action)
            .modifier(DefaultButtonStyle()) // if this modifier is used on context menu buttons everything breaks
    }
    
    public static func context(doneStyle: Bool = false,
                               isEnabled: Bool = true,
                               action: @escaping Action)
                               -> some View
    {
        Button(action: action) {
            self.label()
                .modifier(DoneStyle(enabled: doneStyle))
        }
        .disabled(!isEnabled)
        .help(self.phrase.rawValue)
        .modifier(Shortcut(self.shortcut))
    }
    /// crashes if Icon is NIL
    public static func button_iconOnly(doneStyle: Bool = false,
                                       isEnabled: Bool = true,
                                       action: @escaping Action)
                                       -> some View
    {
        Button(action: action) {
            self.icon!
        }
        .disabled(!isEnabled)
        .help(self.phrase.rawValue)
        .modifier(Shortcut(self.shortcut))
        .modifier(DefaultButtonStyle())
    }
}

extension Toolbarable {
    public static func toolbar(isEnabled: Bool = true,
                               bundle: LocalizeBundle,
                               action: @escaping Action) -> some View {
        return Button(action: action) {
            self.label()
                .modifier(__Hack_ToolbarButtonStyle())
        }
        .disabled(!isEnabled)
        .help(self.phrase.loc(bundle))
        .modifier(Shortcut(self.shortcut))
    }
    
    public static func __fake_macOS_toolbar(isEnabled: Bool = true,
                                            bundle: LocalizeBundle,
                                            action: @escaping Action) -> some View
    {
        #if os(macOS)
        return Button(action: action) {
            self.icon!
                .modifier(__Hack_ToolbarButtonStyle())
        }
        .disabled(!isEnabled)
        .help(self.phrase.loc(bundle))
        .modifier(Shortcut(self.shortcut))
        #else
        return self.toolbar(isEnabled: isEnabled,
                            bundle: bundle,
                            action: action)
        #endif
    }
}

internal struct __Hack_ToolbarButtonStyle: ViewModifier {
    @Environment(\.isEnabled) private var isEnabled
    internal func body(content: Content) -> some View {
        #if os(macOS)
        return content
            .modifier(STZ.CLR.TB.Tint.foreground())
            .opacity(self.isEnabled ? 1.0 : 0.5 )
        #else
        return content
        #endif
    }
}
