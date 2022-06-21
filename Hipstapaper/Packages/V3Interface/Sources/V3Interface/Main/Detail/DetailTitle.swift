//
//  Created by Jeffrey Bergier on 2022/06/22.
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
import V3Store

extension ViewModifier where Self == DetailTitle {
    internal static func detailTitle(_ input: Binding<String?>?) -> Self { Self.init(input) }
}

internal struct DetailTitle: ViewModifier {

    @Nav private var nav
    @QueryProperty private var query
    
    @Binding private var name: String?
    
    internal init(_ input: Binding<String?>?) {
        _name = input ?? Binding(get: { nil }, set: { _ in })
    }
    
    internal func body(content: Content) -> some View {
        switch self.nav.selectedTags?.kind ?? .user {
        case .systemUnread:
            content.navigationTitle("Unread Items")
        case .systemAll:
            content.navigationTitle("All Items")
        case .user:
            let new = Binding<String> {
                self.name ?? "Untitled Tag"
            } set: {
                self.name = $0
            }
            content.navigationTitle(new) {
                Text("// TODO: Add Delete Option")
            }
        }
    }
}
