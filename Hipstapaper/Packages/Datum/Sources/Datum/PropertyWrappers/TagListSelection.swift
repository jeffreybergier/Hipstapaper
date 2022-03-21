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
    
    private let defaultValue = TagListSelection.notATag(.unread)
    
    public init() { }
    
    public var wrappedValue: TagListSelection {
        get { self.projectedValue.wrappedValue ?? .notATag(.unread) }
        nonmutating set { self.projectedValue.wrappedValue = newValue }
    }
    
    public var projectedValue: Binding<TagListSelection?> {
        Binding {
            self.selection
                .map { TagListSelection(rawValue: $0) ?? self.defaultValue }
                ?? self.defaultValue
        } set: {
            self.selection = $0?.rawValue ?? self.defaultValue.rawValue
        }
    }
}

public enum NotATag: String, Identifiable, CaseIterable {
    case unread = "NotATag.Unread"
    case all = "NotATag.All"
    public var id: String { self.rawValue }
}

public enum TagListSelection: RawRepresentable, Hashable {

    case notATag(NotATag), tag(Tag)
    
    public var identValue: Tag.Ident? {
        switch self {
        case .notATag:
            return nil
        case .tag(let tag):
            return tag.uuid
        }
    }
    
    public var rawValue: String {
        switch self {
        case .notATag(let tag):
            return tag.id
        case .tag(let tag):
            do {
                let data = try PropertyListEncoder().encode(tag)
                return data.base64EncodedString()
            } catch {
                error.log()
                return ""
            }
        }
    }
    
    public init?(rawValue: String) {
        if let notATag = NotATag(rawValue: rawValue) {
            self = .notATag(notATag)
            return
        }
        do {
            let data = Data(base64Encoded: rawValue) ?? Data()
            let tag = try PropertyListDecoder().decode(Tag.self, from: data)
            self = .tag(tag)
        } catch {
            return nil
        }
    }

}
