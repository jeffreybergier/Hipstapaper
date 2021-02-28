//
//  Created by Jeffrey Bergier on 2020/12/02.
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

import Localize
import Umbrella

extension Query.Filter: Tag {
    
    public static var anyTag_allCases: [AnyElementObserver<AnyTag>] {
        self.allCases.map { AnyElementObserver(StaticElement(AnyTag($0))) }
    }
    
    // TODO: See if its possible change type to LocalizedString
    public var localizedDescription: String {
        switch self {
        case .all:
            return Noun.allItems_L
        case .unarchived:
            return Noun.unreadItems_L
        }
    }
    
    public var name: String? { self.localizedDescription }
    public var websitesCount: Int? { return nil }
    public var dateCreated: Date { fatalError() }
    public var dateModified: Date { fatalError() }
}

fileprivate struct Blank: Tag, Website {
    var name: String?
    var websitesCount: Int?
    var isArchived: Bool = false
    var originalURL: URL?
    var resolvedURL: URL?
    var preferredURL: URL?
    var title: String?
    var thumbnail: Data?
    var dateCreated: Date = Date()
    var dateModified: Date = Date()
    var id: ObjectIdentifier = ObjectIdentifier(String(Int.random(in: 0...100_000)) as NSString)
}
