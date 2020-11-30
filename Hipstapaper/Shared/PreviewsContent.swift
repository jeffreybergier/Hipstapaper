//
//  Created by Jeffrey Bergier on 2020/11/30.
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

#if DEBUG

import Datum

let p_tags: AnyCollection<AnyElement<AnyTag>> = {
    let date1 = Date(timeIntervalSinceNow: -700)
    let date2 = Date(timeIntervalSinceNow: 0)
    let tag1 = P_Tag(name: "Videos", websitesCount: 3, dateCreated: date1, dateModified: date1, id: .init(NSString("")))
    let tag2 = P_Tag(name: "Japan", websitesCount: 8, dateCreated: date2, dateModified: date2, id: .init(NSString("")))
    let tag3 = P_Tag(name: nil, websitesCount: 20, dateCreated: date2, dateModified: date2, id: .init(NSString("")))
    let element1 = AnyElement(P_Element(AnyTag(tag1)))
    let element2 = AnyElement(P_Element(AnyTag(tag2)))
    let element3 = AnyElement(P_Element(AnyTag(tag3)))
    let collection = P_Collection([element1, element2, element3])
    return AnyCollection(collection)
}()

let p_sites: AnyCollection<AnyElement<AnyWebsite>> = {
    let date1 = Date(timeIntervalSinceNow: -700)
    let date2 = Date(timeIntervalSinceNow: 0)
    let site1 = P_Website(.init(title: "Google.com", resolvedURL: URL(string: "https://www.google.com")!),
                          dateCreated: date1,
                          dateModified: date1,
                          id: .init(NSString("")))
    let site2 = P_Website(.init(title: "Apple.com", originalURL: URL(string: "https://www.apple.com")!),
                          dateCreated: date1,
                          dateModified: date1,
                          id: .init(NSString("")))
    let element1 = AnyElement(P_Element(AnyWebsite(site1)))
    let element2 = AnyElement(P_Element(AnyWebsite(site2)))
    let collection = P_Collection([element1, element2])
    return AnyCollection(collection)
}()

struct P_Tag: Tag {
    var name: String?
    var websitesCount: Int
    var dateCreated: Date
    var dateModified: Date
    var id: ObjectIdentifier
}

struct P_Website: Website {
    var isArchived: Bool
    var originalURL: URL?
    var resolvedURL: URL?
    var title: String?
    var thumbnail: Data?
    var dateCreated: Date
    var dateModified: Date
    var id: ObjectIdentifier
    
    init(_ raw: AnyWebsite.Raw, dateCreated: Date, dateModified: Date, id: ObjectIdentifier) {
        self.isArchived = raw.isArchived ?? false
        self.originalURL = raw.originalURL ?? nil
        self.resolvedURL = raw.resolvedURL ?? nil
        self.title = raw.title ?? nil
        self.thumbnail = raw.thumbnail ?? nil
        self.dateCreated = dateCreated
        self.dateModified = dateModified
        self.id = id
    }
}

class P_Element<T>: Element {
    typealias Value = T
    var value: T
    var isDeleted: Bool = false
    init(_ value: T) {
        self.value = value
    }
}

class P_Collection<Element>: Collection {
    
    private let wrapped: [Element]
    
    init(_ wrapped: [Element]) {
        self.wrapped = wrapped
    }
    
    // MARK: Swift.Collection Boilerplate
    typealias Index = Int
    typealias Element = Element
    var startIndex: Index { self.wrapped.startIndex }
    var endIndex: Index { self.wrapped.endIndex }
    subscript(index: Index) -> Iterator.Element { self.wrapped[index] }
    func index(after index: Index) -> Index { self.wrapped.index(after: index) }
}

#endif
