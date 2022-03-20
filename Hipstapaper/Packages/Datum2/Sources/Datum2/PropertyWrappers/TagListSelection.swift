//
//  Created by Jeffrey Bergier on 2022/03/20.
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

@propertyWrapper
public struct TagListSelectionProperty: DynamicProperty {
    
    @SceneStorage("TagListSelection") private var selection: String?
    
    public init() { }
    
    public var wrappedValue: TagListSelection {
        get { self.projectedValue.wrappedValue ?? .notATag(.unread) }
        nonmutating set { self.projectedValue.wrappedValue = newValue }
    }
    
    public var projectedValue: Binding<TagListSelection?> {
        Binding {
            guard let rawValue = self.selection else { return nil }
            return TagListSelection(rawValue: rawValue)
        } set: {
            self.selection = $0?.rawValue
        }
    }
}

public enum NotATag: String, Identifiable, CaseIterable {
    case unread = "NotATag.Unread"
    case all = "NotATag.All"
    public var id: String { self.rawValue }
}

public enum TagListSelection: RawRepresentable, Hashable {

    case notATag(NotATag), tag(tag: Tag.Ident, name: String?)
    
    public var identValue: Tag.Ident? {
        switch self {
        case .notATag:
            return nil
        case .tag(let tag, _):
            return tag
        }
    }
    
    public var rawValue: String {
        switch self {
        case .notATag(let tag):
            return tag.id
        case .tag(let tag, let name):
            if let name = name {
                return tag.id + "~~" + name
            } else {
                return tag.id
            }
        }
    }
    
    public init?(rawValue: String) {
        if let notATag = NotATag(rawValue: rawValue) {
            self = .notATag(notATag)
            return
        }
        let pieces = rawValue.components(separatedBy: "~~")
        self = .tag(tag: .init(rawValue: pieces[0]), name: pieces.last)
    }

}
