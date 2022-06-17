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

public typealias Action = () -> Void

public struct Toolbar {
    public var systemImage: String
    public var shortcut: KeyboardShortcut?
    
    internal static let tagEdit = Toolbar(
        systemImage: SystemImage.tag.rawValue,
        shortcut: nil
    )
    internal static let tagAdd = Toolbar(
        systemImage: SystemImage.tag.rawValue,
        shortcut: nil
    )
    internal static let websiteAdd = Toolbar(
        systemImage: SystemImage.document.rawValue,
        shortcut: nil
    )
    internal static let genericAdd = Toolbar(
        systemImage: SystemImage.plus.rawValue,
        shortcut: .init("n", modifiers: .command)
    )
    internal static let genericDelete = Toolbar(
        systemImage: SystemImage.trash.rawValue,
        shortcut: .init("n", modifiers: .command)
    )
}

extension Toolbar {
    public func button(_ titleKey: LocalizedStringKey,
                       role: ButtonRole? = nil,
                       action: @escaping Action) -> some View
    {
        Button(role: role, action: action) {
            self.label(titleKey)
        }
        .keyboardShortcut(self.shortcut)
    }
    
    public func label(_ titleKey: LocalizedStringKey) -> some View {
        Label(titleKey, systemImage: self.systemImage)
    }
}
