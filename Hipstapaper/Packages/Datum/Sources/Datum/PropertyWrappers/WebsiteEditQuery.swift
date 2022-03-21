//
//  Created by Jeffrey Bergier on 2022/03/20.
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
public struct WebsiteEditQuery: DynamicProperty {
    
    private let id: Website.Ident
    @ErrorQueue private var errorQ
    @ControllerProperty private var controller
    @ObservedObject private var cd_website: NilBox<CD_Website> = .init()
    @Environment(\.managedObjectContext) private var context

    public init(id: Website.Ident) {
        self.id = id
    }
    
    public func update() {
        guard self.cd_website.value == nil else { return }
        let controller = self.controller as! CD_Controller
        let id = controller.container.persistentStoreCoordinator.managedObjectID(forURIRepresentation: URL(string: id.id)!)!
        let cd_website = controller.container.viewContext.object(with: id) as! CD_Website
        self.cd_website.value = cd_website
    }
    
    public var wrappedValue: Website {
        // TODO: Make not unwrapped?
        Website(self.cd_website.value!)
    }
    public var projectedValue: Binding<Website> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.cd_website.value!.cd_title = newValue.title
                self.cd_website.value!.cd_isArchived = newValue.isArchived
                self.cd_website.value!.cd_resolvedURL = newValue.resolvedURL
                self.cd_website.value!.cd_originalURL = newValue.originalURL
                self.cd_website.value!.cd_thumbnail = newValue.thumbnail
                guard case .failure(let error) = self.context.datum_save() else { return }
                self.errorQ = error
            }
        )
    }
}
