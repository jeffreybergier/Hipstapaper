//
//  Created by Jeffrey Bergier on 2020/12/14.
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

internal func _ToggleDefault(label: TextProvider,
                            initialValue: Bool,
                            valueChanged: @escaping BoolChange)
                            -> some View
{
    return ManualToggle(initialValue: initialValue,
                        content:
                            { () -> AnyView in
                                switch label {
                                case .localized(let title):
                                    return AnyView(Text.IndexRowTitleDisabled(title))
                                case .raw(let title):
                                    return AnyView(Text.IndexRowTitle(title))
                                }
                            },
                        valueChanged: valueChanged)
}

public func ToggleDefault(label: String?,
                          initialValue: Bool,
                          valueChanged: @escaping BoolChange)
                          -> some View
{
    let provider: TextProvider
    if let label = label {
        provider = .raw(label)
    } else {
        provider = .localized(Untitled)
    }
    return _ToggleDefault(label: provider,
                          initialValue: initialValue,
                          valueChanged: valueChanged)
}

public typealias BoolChange = (Bool) -> Void
private struct BoolWrapper {
    let valueChanged: BoolChange
    var value: Bool {
        didSet {
            self.valueChanged(self.value)
        }
    }
}

public struct ManualToggle<Content>: View where Content: View {
    
    let content: () -> Content
    @State private var value: BoolWrapper
    
    public var body: some View {
        Toggle(isOn: self.$value.value, label: self.content)
        //.toggleStyle(SwitchToggleStyle())
    }
    
    public init(initialValue: Bool,
                @ViewBuilder content: @escaping () -> Content,
                valueChanged: @escaping BoolChange)
    {
        _value = State(initialValue: BoolWrapper(valueChanged: valueChanged, value: initialValue))
        self.content = content
    }
}
