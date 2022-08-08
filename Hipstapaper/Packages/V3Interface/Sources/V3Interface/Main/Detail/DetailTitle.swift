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
import V3Localize

internal struct DetailTitle: ViewModifier {

    @Nav private var nav
    @Query private var query
    @TagUserQuery private var item: Tag?
    @V3Localize.Detail private var text
    
    internal func body(content: Content) -> some View {
        Group {
            switch self.nav.sidebar.selectedTag?.kind ?? .user {
            case .systemUnread:
                content.navigationTitle(self.text.titleUnread)
            case .systemAll:
                content.navigationTitle(self.text.titleAll)
            case .user:
                if let item = self.$item {
                    content.navigationTitle(item.name.compactMap(default: self.text.tagUntitled))
                    // TODO: Figure out what happened to this API
                    /*
                    {
                        Text("// TODO: Add Delete Option")
                    }
                    */
                } else {
                    content.navigationTitle(self.text.noTagSelected)
                }
            }
        }
        .navigationBarTitleDisplayModeInline
        .onLoadChange(of: self.nav.sidebar.selectedTag) {
            _item.setIdentifier($0)
        }
    }
}
