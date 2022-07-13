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
public struct WebsiteListQuery: DynamicProperty {
    
    // Basics
    @Controller private var controller
    @CDListQuery<CD_Website, Website, Error>(onRead: Website.init(_:)) private var data
    @Environment(\.managedObjectContext) private var context
    @Environment(\.codableErrorResponder) private var errorResponder
    
    // State
    @StateObject private var query: BlackBox<Query>
    @StateObject private var filter: BlackBox<Tag.Selection.Element?>
        
    public init() {
        // TODO: make Query that results in `NOPREDICATE`
        _query = .init(wrappedValue: .init(.default, isObservingValue: false))
        _filter = .init(wrappedValue: .init(nil, isObservingValue: false))
    }
    
    private let needsUpdate = BlackBox(true, isObservingValue: false)
    public func update() {
        guard self.needsUpdate.value else { return }
        self.needsUpdate.value = false
        _data.setOnWrite(self.cd_controller?.write(_:with:))
        _data.setOnError { error in
            NSLog(String(describing: error))
            self.errorResponder(.init(error as NSError))
        }
        self.updateCoreData()
    }
    
    public var wrappedValue: some RandomAccessCollection<Website> {
        self.data
    }
    
    public var projectedValue: some RandomAccessCollection<Binding<Website>> {
        self.$data
    }
    
    public func setFilter(_ selection: Tag.Selection.Element?) {
        self.filter.value = selection
        self.updateCoreData()
    }
    
    public func setQuery(_ query: Query) {
        self.query.value = query
        self.updateCoreData()
    }
    
    private func updateCoreData() {
        // take query and filter, generate predicate + sort
        let pred = self.query.value.cd_predicate(self.currentTag())
        let sort = self.query.value.cd_sortDescriptor
        // set on _data
        _data.setPredicate(pred)
        _data.setSortDescriptors(sort)
    }
    
    private func currentTag() -> CD_Tag? {
        let context = self.context
        guard
            let psc = context.persistentStoreCoordinator,
            let filter = self.filter.value,
            filter.isSystem == false,
            let url = URL(string: filter.id),
            let objectID = psc.managedObjectID(forURIRepresentation: url)
        else { return nil }
        return context.object(with: objectID) as? CD_Tag
    }
    
    private var cd_controller: CD_Controller? {
        self.controller as? CD_Controller
    }
}
