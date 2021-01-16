//
//  Created by Jeffrey Bergier on 2021/01/01.
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
import Stylize

extension DetailToolbar {
    enum iOS { }
}

extension DetailToolbar.iOS {
    struct Shared: ViewModifier {
        
        @ObservedObject var controller: WebsiteController
        @Binding var popoverAlignment: Alignment
        
        @Environment(\.editMode) private var editMode
        @Environment(\.horizontalSizeClass) private var horizontalSizeClass
        
        func body(content: Content) -> some View {
            switch (self.horizontalSizeClass?.isCompact ?? true,
                    self.editMode?.wrappedValue.isEditing ?? false)
            {
            case (true, true): // iPhone editing
                return AnyView(
                    content
                )
            case (true, false): // iPhone not editing
                return AnyView(
                    content
                )
            case (false, true): // iPad editing
                return AnyView(
                    content.modifier(iPadEdit(controller: self.controller,
                                              popoverAlignment: self.$popoverAlignment))
                )
            case (false, false): // iPad not editing
                return AnyView(
                    content.modifier(iPad(controller: self.controller,
                                          popoverAlignment: self.$popoverAlignment))
                )
            }
        }
    }
}

extension UserInterfaceSizeClass {
    fileprivate var isCompact: Bool {
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

extension EditMode {
    fileprivate var isEditing: Bool {
        switch self {
        case .transient, .active:
            return true
        case .inactive:
            fallthrough
        @unknown default:
            return false
        }
    }
}
