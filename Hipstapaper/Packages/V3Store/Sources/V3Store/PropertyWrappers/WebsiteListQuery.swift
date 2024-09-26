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

@MainActor
@propertyWrapper
public struct WebsiteListQuery: DynamicProperty {
    
    public struct Value<C> {
        public let data: C
        public var configuration: Configuration
    }
    
    public struct Configuration: Equatable {
        public var query: Query?
        public var filter: Tag.Selection.Element?
    }
    
    @State private var configuration: Configuration = .init()
    @Environment(\.managedObjectContext) private var context
    @CDListQuery<CD_Website, Website.Identifier>(onRead: { Website.Identifier($0.objectID) }) private var query
    
    public init() { }
    
    public var wrappedValue: Value<some RandomAccessCollection<Website.Identifier>> {
        get { .init(data: self.query.data, configuration: self.configuration) }
        nonmutating set { self.write(newValue.configuration) }
    }
    
    private func write(_ newValue: Configuration) {
        let oldConfiguration = self.configuration
        self.configuration = newValue
        guard oldConfiguration != newValue else { return }
        
        let input = newValue
        var output = self.query.configuration
        guard
            var query = input.query,
            let filter = input.filter
        else {
            output.sortDescriptors = [Sort.default.cd_sortDescriptor]
            output.predicate = .init(value: false)
            self.query.configuration = output
            return
        }
        
        var currentTag: CD_Tag?
        switch filter.kind {
        case .systemAll:
            query.isOnlyNotArchived = false
        case .systemUnread:
            query.isOnlyNotArchived = true
        default:
            let context = self.context
            guard
                let url = URL(string: filter.id.rawValue),
                let psc = context.persistentStoreCoordinator,
                let objectID = psc.managedObjectID(forURIRepresentation: url)
            else { break }
            currentTag = context.object(with: objectID) as? CD_Tag
        }
        
        output.predicate = query.cd_predicate(currentTag)
        output.sortDescriptors = [query.sort.cd_sortDescriptor]
        self.query.configuration = output
    }
}
