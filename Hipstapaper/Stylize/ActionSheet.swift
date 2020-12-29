//
//  Created by Jeffrey Bergier on 2020/12/26.
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

public struct ActionSheet: ViewModifier {
    
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
    
    @Binding public var isPresented: Bool
    public var title: LocalizedStringKey
    public var message: LocalizedStringKey? = nil
    public var buttons: [Button]
    
    public init(isPresented: Binding<Bool>,
                title: LocalizedStringKey,
                message: LocalizedStringKey? = nil,
                buttons: [Button])
    {
        _isPresented = isPresented
        self.title = title
        self.message = message
        self.buttons = buttons
    }
}

extension ActionSheet {
    
#if os(macOS)
public func body(content: Content) -> some View {
    return content.popover(isPresented: self.$isPresented) {
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
        .paddingDefault_Equal()
    }
}

#else
public func body(content: Content) -> some View {
    return content.actionSheet(isPresented: self.$isPresented) {
        return SwiftUI.ActionSheet(
            title: Text(self.title),
            message: self.message.map { Text($0) },
            buttons: self.buttons.map { $0.nativeValue }
        )
    }
}

#endif
}

extension ActionSheet.Button {
#if os(macOS)
var nativeValue: some View {
    return SwiftUI.Button(
        action: self.action,
        label: {
            Text(self.title)
                .font(.headline)
                .frame(minWidth: 200, maxWidth: 200)
        }
    )
}
#else
var nativeValue: Alert.Button {
    switch self.kind {
    case .cancel:
        return .cancel(Text(self.title), action: self.action)
    case .default:
        return .default(Text(self.title), action: self.action)
    case .destructive:
        return .destructive(Text(self.title), action: self.action)
    }
}
#endif
}
