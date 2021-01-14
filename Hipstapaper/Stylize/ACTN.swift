//
//  Created by Jeffrey Bergier on 2021/01/13.
//
//  Copyright © 2020 Saturday Apps.
//
//  This file is part of Hipstapaper.
//
//  Hipstapaper is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Hipstapaper is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Hipstapaper.  If not, see <http://www.gnu.org/licenses/>.
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
            // TODO: Make this text wrap
            Text(self.title)
                .font(.body)
                .foregroundColor(Color.textTitleDisabled)
                .frame(maxWidth: 200)
                .lineLimit(nil)
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
                Text(self.title)
                    .font(.headline)
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
                + [.cancel(Text(Verb.Cancel))]
        )
    }
}

extension STZ.ACTN.Wrapper.Button {
    internal var nativeValue: Alert.Button {
        switch self.kind {
        case .cancel:
            return .cancel(Text(self.title), action: self.action)
        case .default:
            return .default(Text(self.title), action: self.action)
        case .destructive:
            return .destructive(Text(self.title), action: self.action)
        }
    }
}
#endif
