//
//  Created by Jeffrey Bergier on 2022/03/16.
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
import Localize

@propertyWrapper
public struct TagEditQuery: DynamicProperty {
    
    private let id: Tag.Ident
    @ErrorQueue private var errorQ
    @ControllerProperty private var controller
    @ObservedObject private var cd_tag: NilBox<CD_Tag> = .init()
    @Environment(\.managedObjectContext) private var context

    // TODO: Move controller into the environment
    public init(id: Tag.Ident) {
        self.id = id
    }
    
    public func update() {
        guard self.cd_tag.value == nil else { return }
        let controller = self.controller as! CD_Controller
        let id = controller.container.persistentStoreCoordinator.managedObjectID(forURIRepresentation: URL(string: id.id)!)!
        let cd_tag = controller.container.viewContext.object(with: id) as! CD_Tag
        self.cd_tag.value = cd_tag
    }
    
    public var wrappedValue: Tag {
        Tag(self.cd_tag.value!)
    }
    public var projectedValue: Binding<Tag> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.cd_tag.value!.cd_name = newValue.name
                guard case .failure(let error) = self.context.datum_save() else { return }
                self.errorQ = error
            }
        )
    }
}
