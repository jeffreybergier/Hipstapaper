//
//  Created by Jeffrey Bergier on 2021/02/17.
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

extension Binding where Value == EditMode {
    public var isEditing: Bool {
        switch self.wrappedValue {
        case .transient, .active:
            return true
        case .inactive:
            fallthrough
        @unknown default:
            return false
        }
    }
}

extension UserInterfaceSizeClass {
    public var isCompact: Bool {
        switch self {
        case .regular:
            return false
        case .compact:
            fallthrough
        @unknown default:
            return true
        }
    }
}

public enum Force {
    public struct EditMode: ViewModifier {
        #if canImport(UIKit)
        @State var editMode: SwiftUI.EditMode = .active
        #endif
        public init() {}
        public func body(content: Content) -> some View {
            #if canImport(UIKit)
            return content.environment((\.editMode), self.$editMode)
            #else
            return content
            #endif
        }
    }
    public struct PlainListStyle: ViewModifier {
        public init() {}
        public func body(content: Content) -> some View {
            #if canImport(UIKit)
            return content.listStyle(SwiftUI.PlainListStyle())
            #else
            return content
            #endif
        }
    }
}
