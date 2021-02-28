//
//  Created by Jeffrey Bergier on 2020/11/28.
//
//  MIT License
//
//  Copyright (c) 2021 jeffreybergier
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

extension Query {
    internal var cd_sortDescriptors: [NSSortDescriptor] { self.sort.cd_sortDescriptors }
    internal var cd_predicate: NSPredicate? {
        let predicates: [NSPredicate] = [
            {
                guard case .unarchived = self.filter else { return nil }
                return NSPredicate(format: "%K == NO", #keyPath(CD_Website.cd_isArchived))
            }(),
            {
                guard let search = self.search.trimmed else { return nil }
                return NSCompoundPredicate(orPredicateWithSubpredicates: [
                    NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(CD_Website.cd_title), search),
                    NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(CD_Website.cd_resolvedURL), search),
                    NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(CD_Website.cd_originalURL), search),
                ])
            }(),
            {
                guard let _tag = self.tag else { return nil }
                guard let tag = _tag.value.wrappedValue as? CD_Tag
                else { assertionFailure("Invalid TAG Object"); return nil; }
                return NSPredicate(format: "%K CONTAINS %@", #keyPath(CD_Website.cd_tags), tag)
            }(),
        ].compactMap { $0 }
        guard predicates.isEmpty == false else { return nil }
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
}
