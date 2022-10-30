//
//  Created by Jeffrey Bergier on 2022/07/27.
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
import V3Model

// TODO: Replace `TEXT` with L: View when TableColumn allows custom view types for Label
internal typealias HACK_ColumnUnsorted<V: View> = TableColumn<HACK_WebsiteIdentifier, Never, V, Text>
internal typealias HACK_ColumnSorted<V: View>   = TableColumn<HACK_WebsiteIdentifier, KeyPathComparator<HACK_WebsiteIdentifier>, V, Text>

// TODO: EditMode works like shit as of iOS 16.1. It constantly pops out for no reason
// I need to make my own version.
@propertyWrapper
internal struct HACK_EditMode: DynamicProperty {
    @SceneStorage("HACK_EditMode") private var value = false
    internal var wrappedValue: Bool {
        get { self.value }
        nonmutating set { self.value = newValue }
    }
    internal var projectedValue: Binding<Bool> {
        Binding {
            self.wrappedValue
        } set: {
            self.wrappedValue = $0
        }
    }
}

internal struct HACK_EditButton: View {
    
    @Selection private var selection
    @HACK_EditMode private var isEditMode
    
    internal var body: some View {
        Button {
            self.selection.websites = []
            self.isEditMode.toggle()
        } label: {
            // TODO: Localize
            self.isEditMode ? Text("Done") : Text("Edit")
        }
    }
}

// TODO: Delete when possible
// Table does not appear to let you choose how you identify
// the object. It always chooses the ID property for what it is passed.
// This is a problem when I am passing the identifier itself.
internal struct HACK_WebsiteIdentifier: Identifiable {
    internal var id: Website.Identifier
    internal init(_ id: Website.Identifier) {
        self.id = id
    }
}

// Hack to make Keypaths work for column sorting
extension HACK_WebsiteIdentifier {
    internal var title: String? { fatalError() }
    internal var dateModified: Date? { fatalError() }
    internal var dateCreated: Date? { fatalError() }
}

extension Binding where Value == Sort {
    internal var HACK_mapSort: Binding<[KeyPathComparator<HACK_WebsiteIdentifier>]> {
        self.map { value in
            switch value {
            case .dateCreatedNewest:
                return [.init(\.dateCreated, order: .reverse)]
            case .dateCreatedOldest:
                return [.init(\.dateCreated, order: .forward)]
            case .dateModifiedNewest:
                return [.init(\.dateModified, order: .reverse)]
            case .dateModifiedOldest:
                return [.init(\.dateModified, order: .forward)]
            case .titleA:
                return [.init(\.title, order: .reverse)]
            case .titleZ:
                return [.init(\.title, order: .forward)]
            }
        } set: {
            guard let newValue = $0.first else { return .default }
            switch (newValue.keyPath, newValue.order) {
            case (\.title, .reverse):
                return .titleA
            case (\.title, .forward):
                return .titleZ
            case (\.dateCreated, .reverse):
                return .dateCreatedNewest
            case (\.dateCreated, .forward):
                return .dateCreatedOldest
            case (\.dateModified, .reverse):
                return .dateModifiedNewest
            case (\.dateModified, .forward):
                return .dateModifiedOldest
            default:
                return .default
            }
        }
    }
}
