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

import SwiftUI
import Umbrella
import V3Model

@propertyWrapper
public struct TagUserListQuery: DynamicProperty {
    
    @Controller private var controller
    @CDListQuery<CD_Tag, Tag, Error>(onRead: Tag.init(_:)) private var data
    @StateObject private var predicate: BlackBox<NSPredicate>
    
    @Environment(\.managedObjectContext) private var context
    @Environment(\.codableErrorResponder) private var errorResponder
        
    public init(defaultListAll: Bool = true) {
        _predicate = .init(wrappedValue: .init(.init(value: defaultListAll), isObservingValue: false))
    }
    
    private let needsUpdate = BlackBox(true, isObservingValue: false)
    public func update() {
        guard self.needsUpdate.value else { return }
        self.needsUpdate.value = false
        _data.setPredicate(self.predicate.value)
        _data.setSortDescriptors([CD_Tag.defaultSort])
        _data.setOnWrite(_controller.cd.write(_:with:))
        _data.setOnError { error in
            NSLog(String(describing: error))
            self.errorResponder(.init(error as NSError))
        }
    }
    
    public var wrappedValue: some RandomAccessCollection<Tag> {
        self.data
    }
    
    public var projectedValue: some RandomAccessCollection<Binding<Tag>> {
        self.$data
    }
    
    public func setQuery(_ selection: Tag.Selection) {
        guard
            selection.isEmpty == false,
            let psc = self.context.persistentStoreCoordinator
        else { return }
        let preds = selection
            .compactMap { URL(string: $0.id) }
            .compactMap { psc.managedObjectID(forURIRepresentation: $0) }
            .map { NSPredicate(format: "(objectID = %@)", $0) }
        let pred = NSCompoundPredicate(orPredicateWithSubpredicates: preds)
        self.predicate.value = pred
        _data.setPredicate(pred)
    }
}
