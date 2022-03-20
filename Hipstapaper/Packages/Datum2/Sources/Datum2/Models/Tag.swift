//
//  Created by Jeffrey Bergier on 2022/03/12.
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

import Foundation

public struct Tag: Identifiable, Hashable, Codable {
    public var name: String?
    public var websitesCount: Int?
    
    public var id: String { self.uuid.id }
    public var uuid: Ident
    public var dateCreated: Date
    public var dateModified: Date
    
    public struct Ident: Identifiable, Hashable, Codable {
        public var id: String
    }
}

extension Tag.Ident: RawRepresentable {
    public var rawValue: String {
        return self.id
    }
    public init(rawValue: String) {
        self.id = rawValue
    }
}

public enum TagListSelection: RawRepresentable {

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

public enum NotATag: String, Identifiable, CaseIterable {
    case unread = "NotATag.Unread"
    case all = "NotATag.All"
    public var id: String { self.rawValue }
}
