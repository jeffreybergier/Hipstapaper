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
    @CDListQuery<CD_Website, Website, Error>(
        predicate: NSPredicate(value: false),
        onRead: Website.init(_:)
    ) private var data
    @Environment(\.managedObjectContext) private var context
    @Environment(\.codableErrorResponder) private var errorResponder
    
    // State
    @State private var query: Query?
    @State private var filter: Tag.Selection.Element?
        
    public init() { }
    
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
        self.filter = selection
        self.updateCoreData()
    }
    
    public func setQuery(_ query: Query) {
        self.query = query
        self.updateCoreData()
    }
    
    private func updateCoreData() {
        guard var query = self.query else {
            _data.setPredicate(.init(value: false))
            _data.setSortDescriptors([Sort.default.cd_sortDescriptor])
            return
        }
        if let filter = self.filter, filter.isSystem {
            switch filter {
            case .systemAll:
                query.isOnlyNotArchived = false
            case .systemUnread:
                query.isOnlyNotArchived = true
            default:
                break
            }
        }
        _data.setPredicate(query.cd_predicate(self.currentTag()))
        _data.setSortDescriptors([query.sort.cd_sortDescriptor])
    }
    
    private func currentTag() -> CD_Tag? {
        let context = self.context
        guard
            let psc = context.persistentStoreCoordinator,
            let filter = self.filter,
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
