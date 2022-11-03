//
//  Created by Jeffrey Bergier on 2022/06/17.
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

public struct Tag: Identifiable, Hashable, Equatable {
    
    public typealias Selection = Set<Tag.Identifier>
    
    public struct Identifier: Hashable, Equatable, Codable, RawRepresentable, Identifiable {
        
        public enum Kind: String {
            case systemAll, systemUnread, user
        }
        
        public var id: String
        public var kind: Kind = .user
        
        public init(_ rawValue: String, kind: Kind = .user) {
            self.id = rawValue
            self.kind = kind
        }
        
        public var rawValue: String {
            self.kind.rawValue + "|.|.|" + self.id
        }
        public init?(rawValue: String) {
            let comps = rawValue.components(separatedBy: "|.|.|")
            guard
                comps.count == 2,
                let kind = Kind(rawValue: comps[0])
            else {
                return nil
            }
            self.id = comps[1]
            self.kind = kind
        }
    }
    
    public var id: Identifier
    public var name: String?
    public var websitesCount: Int?
    public var dateCreated: Date?
    public var dateModified: Date?
    
    public init(id: Identifier,
                name: String? = nil,
                websitesCount: Int? = nil,
                dateCreated: Date? = nil,
                dateModified: Date? = nil)
    {
        self.id = id
        self.name = name
        self.websitesCount = websitesCount
        self.dateCreated = dateCreated
        self.dateModified = dateModified
    }
}
