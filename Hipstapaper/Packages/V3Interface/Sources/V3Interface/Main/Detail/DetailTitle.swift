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
import V3Model

extension ViewModifier where Self == DetailTitle {
    internal static var detailTitle: Self { Self.init() }
}

internal struct DetailTitle: ViewModifier {
    
    // TODO: Localize

    @Nav private var nav
    @Query private var query
    @TagUserQuery private var item: Tag?
    
    private var repairedBinding: Binding<String> {
        return Binding<String> {
            self.item?.name ?? "Untitled Tag"
        } set: {
            self.item?.name = $0
        }
    }
    
    internal func body(content: Content) -> some View {
        Group {
            switch self.nav.sidebar.selectedTag?.kind ?? .user {
            case .systemUnread:
                content.navigationTitle("Unread Items")
            case .systemAll:
                content.navigationTitle("All Items")
            case .user:
                content.navigationTitle(self.repairedBinding) {
                    Text("// TODO: Add Delete Option")
                }
            }
        }
        .navigationBarTitleDisplayModeInline
        .onLoadChange(of: self.nav.sidebar.selectedTag) {
            _item.setIdentifier($0)
        }
    }
}
