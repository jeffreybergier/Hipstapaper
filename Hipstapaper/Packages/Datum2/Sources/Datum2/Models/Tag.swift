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
        internal init(_ id: String) {
            self.id = id
        }
    }
}

extension Tag.Ident {
    public static let unread = Tag.Ident("unread")
    public static let all = Tag.Ident("all")
    public static let specialTags: [Tag.Ident] = [unread, all]
    public var isSpecialTag: Bool {
        return Self.specialTags.contains(self)
    }
}
