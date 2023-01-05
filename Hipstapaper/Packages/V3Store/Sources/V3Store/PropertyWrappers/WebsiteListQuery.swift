//
//  Created by Jeffrey Bergier on 2022/06/20.
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

@propertyWrapper
public struct FAST_WebsiteListQuery: DynamicProperty {
    
    // Basics
    @Controller private var controller
    @CDListQuery<CD_Website, Website.Identifier, Error>(
        predicate: .init(value: false),
        onRead: { Website.Identifier($0.objectID) }
    ) private var data
    @Environment(\.managedObjectContext) private var context
    @Environment(\.errorResponder) private var errorResponder
    
    // State
    @State private var query: Query?
    @State private var filter: Tag.Selection.Element?
        
    public init() { }
    
    private let needsUpdate = SecretBox(true)
    public func update() {
        guard self.needsUpdate.value else { return }
        self.needsUpdate.value = false
        _data.setOnError { error in
            NSLog(String(describing: error))
            self.errorResponder(error)
        }
        self.updateCoreData()
    }
    
    public var wrappedValue: some RandomAccessCollection<Website.Identifier> {
        self.data
    }
    
    public func setFilter(_ selection: Tag.Selection.Element?) {
        self.filter = selection
        self.updateCoreData()
    }
    
    public func setQuery(_ query: Query) {
        self.query = query
        self.updateCoreData()
    }
    
    private func updateCoreData() {
        guard var query = self.query, let filter = self.filter else {
            _data.setPredicate(.init(value: false))
            _data.setSortDescriptors([Sort.default.cd_sortDescriptor])
            return
        }
        var currentTag: CD_Tag?
        switch filter {
        case .systemAll:
            query.isOnlyNotArchived = false
        case .systemUnread:
            query.isOnlyNotArchived = true
        default:
            let context = self.context
            guard
                let url = URL(string: filter.id),
                let psc = context.persistentStoreCoordinator,
                let objectID = psc.managedObjectID(forURIRepresentation: url)
            else { break }
            currentTag = context.object(with: objectID) as? CD_Tag
        }
        _data.setPredicate(query.cd_predicate(currentTag))
        _data.setSortDescriptors([query.sort.cd_sortDescriptor])
    }
}
