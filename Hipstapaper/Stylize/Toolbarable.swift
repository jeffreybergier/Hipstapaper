//
//  Created by Jeffrey Bergier on 2021/01/11.
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

public protocol Toolbarable {
    static var icon: String { get }
    static var help: LocalizedStringKey { get }
    static var label: LocalizedStringKey { get }
}

fileprivate struct __Hack_ToolbarButtonStyle: ViewModifier {
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.isEnabled) var isEnabled
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(self.colorScheme.isNormal
                                ? Color.toolbarIcon
                                : Color.toolbarIcon_Dark)
            .opacity(self.isEnabled ? 1.0 : 0.5 )
    }
}

extension Toolbarable {
    public static func toolbarButton(isDisabled: Bool = false, action: @escaping Action) -> some View {
        return Button(action: action) {
            Image(systemName: self.icon)
        }
        .modifier(__Hack_ToolbarButtonStyle())
        .disabled(isDisabled)
        .help(self.help)
    }
    
    public static func contextButton(isDisabled: Bool, action: @escaping Action) -> some View {
        return Button(action: action) {
            Label(self.label, systemImage: self.icon)
        }
        .disabled(isDisabled)
        .help(self.help)
    }
}

extension STZ {
    public enum TB {
        public enum TagApply: Toolbarable {
            public static let icon: String = "tag"
            public static let help: LocalizedStringKey = Verb.AddAndRemoveTags
            public static let label: LocalizedStringKey = Verb.AddAndRemoveTags
        }
    }
}
