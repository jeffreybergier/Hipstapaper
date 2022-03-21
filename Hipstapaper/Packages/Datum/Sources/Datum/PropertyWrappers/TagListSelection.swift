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
    
    private var strictValue: TagListSelection? {
        nonmutating set { self.selection = newValue?.rawValue ?? TagListSelection.default.rawValue }
        get {
            return self.selection
                .map { TagListSelection(rawValue: $0) ?? TagListSelection.default }
                ?? TagListSelection.default
        }
    }
    
    private var looseValue: TagListSelection? {
        nonmutating set { self.selection = newValue?.rawValue }
        get {
            guard let rawValue = self.selection else { return nil }
            return TagListSelection(rawValue: rawValue)
        }
    }
    
    public var projectedValue: Binding<TagListSelection?> {
        Binding {
            self.wrappedValue
        } set: {
            self.wrappedValue = $0
        }
    }
    
    // TODO: Remove terrible hack
    // Due to how iOS handles this value when in compact size mode
    // it needs to be allowed to be NIL for iPhones and iPad in Split Screen.
    // But for better UX I want it to never be NIL so it automatically loads
    // the correct default setting.
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var size
    public var wrappedValue: TagListSelection? {
        get {
            if case .compact = self.size {
                return self.looseValue
            } else {
                return self.strictValue
            }
        }
        nonmutating set {
            if case .compact = self.size {
                self.looseValue = newValue
            } else {
                self.strictValue = newValue
            }
        }
    }
    #elseif os(macOS)
    public var wrappedValue: TagListSelection? {
        get { self.strictValue }
        nonmutating set { self.strictValue = newValue }
    }
    #endif
}

public enum NotATag: String, Identifiable, CaseIterable {
    case unread = "NotATag.Unread"
    case all = "NotATag.All"
    public var id: String { self.rawValue }
}

public enum TagListSelection: RawRepresentable, Hashable {
    
    public static let `default` = TagListSelection.notATag(.unread)

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
