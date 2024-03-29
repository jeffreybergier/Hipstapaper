//
//  Created by Jeffrey Bergier on 2022/07/27.
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
import V3Store
import V3Localize
import V3Style

internal struct DetailTableColumnThumbnail: View {
    
    @WebsiteQuery private var query
    @V3Style.DetailTable private var style
    
    private let id: Website.Identifier
    
    internal init(_ id: Website.Identifier) {
        self.id = id
    }
    
    var body: some View {
        self.style.thumbnail(self.query.data?.thumbnail)
            .onChange(of: self.id, initial: true) { _, newValue in
                self.query.identifier = newValue
            }
    }
}

internal struct DetailTableColumnTitle: View {
    
    @WebsiteQuery private var query
    @V3Style.DetailTable private var style
    @V3Localize.DetailTable private var text
    
    private let id: Website.Identifier
    
    internal init(_ id: Website.Identifier) {
        self.id = id
    }
    
    var body: some View {
        JSBText(self.text.missingTitle,
                text: self.query.data?.title)
        .modifier(self.style.title)
        .onChange(of: self.id, initial: true) { _, newValue in
            self.query.identifier = newValue
        }
    }
}

internal struct DetailTableColumnURL: View {
    
    @WebsiteQuery private var query
    @V3Style.DetailTable private var style
    @V3Localize.DetailTable private var text
    
    private let id: Website.Identifier
    
    internal init(_ id: Website.Identifier) {
        self.id = id
    }
    
    var body: some View {
        JSBText(self.text.missingURL,
                text: self.text.prettyURL(self.query.data?.preferredURL))
        .modifier(self.style.url)
        .onChange(of: self.id, initial: true) { _, newValue in
            self.query.identifier = newValue
        }
    }
}

internal struct DetailTableColumnDate: View {
    
    @WebsiteQuery private var query
    @V3Style.DetailTable private var style
    @V3Localize.DetailTable private var text
    
    private let id: Website.Identifier
    private let keyPath: KeyPath<Website, Date?>
    
    internal init(id: Website.Identifier, kp: KeyPath<Website, Date?>) {
        self.id = id
        self.keyPath = kp
    }
    
    var body: some View {
        JSBText(self.text.missingDate,
                text: _text.dateString(self.query.data?[keyPath: self.keyPath]))
        .modifier(self.style.date)
        .onChange(of: self.id, initial: true) { _, newValue in
            self.query.identifier = newValue
        }
    }
}
