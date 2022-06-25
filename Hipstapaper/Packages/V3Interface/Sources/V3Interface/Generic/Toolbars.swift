//
//  Created by Jeffrey Bergier on 2022/06/25.
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

public struct DoneToolbar: ViewModifier {
    
    public struct Action {
        public var title: LocalizedString
        public var action: () -> Void
        public init(title: LocalizedString, action: @escaping () -> Void) {
            self.title = title
            self.action = action
        }
    }
    
    private var title: LocalizedString
    private var done: Action
    private var cancel: Action?
    private var delete: Action?

    public init(title: LocalizedString,
                done: Action,
                cancel: Action? = nil,
                delete: Action? = nil)
    {
        self.title = title
        self.done = done
        self.cancel = cancel
        self.delete = delete
    }
    
    public init(title: LocalizedString,
                done: LocalizedString,
                doneAction: @escaping () -> Void)
    {
        self.title = title
        self.done = .init(title: done, action: doneAction)
    }
    
    public init(title: LocalizedString,
                done: LocalizedString,
                cancel: LocalizedString,
                doneAction: @escaping () -> Void,
                cancelAction: @escaping () -> Void)
    {
        self.title = title
        self.done = .init(title: done, action: doneAction)
        self.cancel = .init(title: cancel, action: cancelAction)
    }
    
    public init(title: LocalizedString,
                done: LocalizedString,
                delete: LocalizedString,
                doneAction: @escaping () -> Void,
                deleteAction: @escaping () -> Void)
    {
        self.title = title
        self.done = .init(title: done, action: doneAction)
        self.delete = .init(title: delete, action: deleteAction)
    }
    
    public func body(content: Content) -> some View {
        content
            .navigationTitle(self.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(self.done.title, action: self.done.action)
                }
                if let cancel {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(cancel.title, role: .cancel, action: cancel.action)
                    }
                } else if let delete {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(delete.title, role: .destructive, action: delete.action)
                    }
                }
            }
    }
}
