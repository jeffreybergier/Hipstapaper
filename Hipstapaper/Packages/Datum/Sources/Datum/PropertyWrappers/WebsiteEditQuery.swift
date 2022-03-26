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
    
    @Environment(\.managedObjectContext) private var context
    @CDObjectQuery<CD_Website, Website, Error> private var object: Website?
    @ControllerProperty private var controller

    public init(id: Website.Ident) {
        _object = .init(objectIDURL: id.url) { Website($0) }
    }
    
    public func update() {
        guard _object.onWrite.value == nil else { return }
        _object.onWrite.value = self.write(_:with:)
    }
    
    public var wrappedValue: Website {
        get { self.object! }
        nonmutating set { self.object = newValue }
    }
    
    public var projectedValue: Binding<Website> {
        self.$object!
    }
    
    // TODO: Move to Controller
    private func write(_ cd: CD_Website?, with newValue: Website?) -> Result<Void, Error> {
        cd!.cd_title       = newValue!.title
        cd!.cd_isArchived  = newValue!.isArchived
        cd!.cd_resolvedURL = newValue!.resolvedURL
        cd!.cd_originalURL = newValue!.originalURL
        cd!.cd_thumbnail   = newValue!.thumbnail
        return self.context.datum_save()
    }
}
