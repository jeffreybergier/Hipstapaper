//
//  Created by Jeffrey Bergier on 2022/12/26.
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
public struct HACK_macOS_Style: DynamicProperty {
    
    public init() {}
    
    public struct Value {
        public var formStyle:              some ViewModifier = HACK_macOS_FormStyle()
        public var toolbarPadding:         some ViewModifier = HACK_macOS_ToolbarPadding()
        public var tabParentPadding:       some ViewModifier = HACK_macOS_ToolbarPadding()
        public var formTextFieldStyle:     some ViewModifier = HACK_macOS_FormTextFieldStyle()
        public var websiteEditPopoverSize: some ViewModifier = HACK_macOS_WebsiteEditPopoverSize()
        public var browserWindowSize:      some ViewModifier = HACK_macOS_BrowserWindowSize()
    }
    
    public var wrappedValue: Value {
        Value()
    }
}

// TODO: Change to private. Causes compile error for some reason
public struct HACK_macOS_FormStyle: ViewModifier {
    public func body(content: Content) -> some View {
        #if os(macOS)
        content.formStyle(.grouped)
        #else
        content
        #endif
    }
}

public struct HACK_macOS_ToolbarPadding: ViewModifier {
    public func body(content: Content) -> some View {
        #if os(macOS)
        content.padding([.leading, .trailing, .bottom])
        #else
        content
        #endif
    }
}

public struct HACK_macOS_FormTextFieldStyle: ViewModifier {
    public func body(content: Content) -> some View {
        #if os(macOS)
        content.textFieldStyle(.squareBorder)
        #else
        content
        #endif
    }
}

public struct HACK_macOS_WebsiteEditPopoverSize: ViewModifier {
    public func body(content: Content) -> some View {
        #if os(macOS)
        content.modifier(PopoverSize(size: .wide))
        #else
        content
        #endif
    }
}

public struct HACK_macOS_BrowserWindowSize: ViewModifier {
    public func body(content: Content) -> some View {
        #if os(macOS)
        content.modifier(SceneSize(size: .small))
        #else
        content
        #endif
    }
}

