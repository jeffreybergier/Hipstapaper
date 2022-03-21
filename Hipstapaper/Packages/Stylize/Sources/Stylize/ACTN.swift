//
//  Created by Jeffrey Bergier on 2021/01/13.
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

extension STZ {
    public enum ACTN {}
}

extension STZ.ACTN {
    public struct Modifier: ViewModifier {
        @Binding public var isPresented: Bool
        public let content: () -> Wrapper
        public func body(content: Content) -> some View {
            let nativeContent = { self.content().nativeValue }
            #if os(macOS)
            return content.popover(isPresented: self.$isPresented,
                                   content: nativeContent)
            #else
            return content.actionSheet(isPresented: self.$isPresented,
                                       content: nativeContent)
            #endif
        }
        public init(isPresented: Binding<Bool>, content: @escaping () -> Wrapper) {
            _isPresented = isPresented
            self.content = content
        }
    }
    
    public struct Wrapper {
        public struct Button {
            public enum Kind {
                case destructive, `default`, cancel
            }
            public var title: LocalizedStringKey
            public var kind: Kind
            public var action: () -> Void
            public init(title: LocalizedStringKey,
                        kind: Kind = .default,
                        action: @escaping () -> Void)
            {
                self.title = title
                self.kind = kind
                self.action = action
            }
        }
        
        public var title: LocalizedStringKey
        public var message: LocalizedStringKey? = nil
        public var buttons: [Button]
        
        public init(title: LocalizedStringKey,
                    message: LocalizedStringKey? = nil,
                    buttons: [Button])
        {
            self.title = title
            self.message = message
            self.buttons = buttons
        }
    }
}

#if os(macOS)
extension STZ.ACTN.Wrapper {
    internal var nativeValue: some View {
        VStack() {
            Text(self.title)
                .modifier(STZ.FNT.ACTN.Body.apply())
                .modifier(STZ.CLR.ACTN.Body.foreground())
                .lineLimit(2) // TODO: Figure out why text won't wrap properly
                .fixedSize(horizontal: false, vertical: true) // TODO: Figure out why text won't wrap properly
                .frame(maxWidth: 200)
            ForEach(0..<self.buttons.count, id: \.self) {
                self.buttons[$0].nativeValue
            }
        }
        .modifier(STZ.PDG.Equal())
    }
}

extension STZ.ACTN.Wrapper.Button {
    internal var nativeValue: some View {
        SwiftUI.Button(
            action: self.action,
            label: {
                STZ.VIEW.TXT(self.title)
                    .modifier(STZ.FNT.Button.Done.apply())
                    .modifier(STZ.CLR.ACTN.Button.foreground())
                    .frame(minWidth: 200, maxWidth: 200)
            }
        )
    }
}
#else
extension STZ.ACTN.Wrapper {
    internal var nativeValue: ActionSheet {
        SwiftUI.ActionSheet(
            title: Text(self.title),
            message: self.message.map { Text($0) },
            buttons: self.buttons
                .map { $0.nativeValue }
                + [.cancel(Text(Verb.cancel.rawValue))]
        )
    }
}

extension STZ.ACTN.Wrapper.Button {
    internal var nativeValue: Alert.Button {
        switch self.kind {
        case .cancel:
            return .cancel(Text(self.title),
                           action: self.action)
        case .default:
            return .default(Text(self.title),
                            action: self.action)
        case .destructive:
            return .destructive(Text(self.title),
                                action: self.action)
        }
    }
}
#endif
