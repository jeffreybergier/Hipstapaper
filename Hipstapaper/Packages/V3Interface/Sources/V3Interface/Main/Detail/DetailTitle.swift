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
import Umbrella
import V3Store
import V3Model
import V3Localize

internal struct DetailTitle: ViewModifier {
    internal func body(content: Content) -> some View {
        #if os(macOS)
        content.modifier(HACK_DetailTitle())
        #else
        content.modifier(IDEAL_DetailTitle())
        #endif
    }
}

private struct IDEAL_DetailTitle: ViewModifier {

    @Selection private var selection
    @TagQuery private var query
    
    @V3Localize.Detail private var text
    
    internal func body(content: Content) -> some View {
        self.$query.view {
            content.navigationTitle($0.name.compactMap())
        } onNIL: {
            content.navigationTitle(self.title)
        }
        .navigationBarTitleDisplayModeInline
        .onLoadChange(of: self.selection.tag) {
            self.query.id = $0
        }
    }
    
    private var title: LocalizedString {
        switch self.selection.tag?.kind ?? .user {
        case .systemUnread:
            return self.text.titleUnread
        case .systemAll:
            return self.text.titleAll
        case .user:
            return self.text.noTagSelected.title
        }
    }
}

// TODO: On Mac the toolbar breaks when the content switches
// from renamable title to regular title. Use this simple one instead.
private struct HACK_DetailTitle: ViewModifier {

    @Selection private var selection
    @TagQuery private var query
    
    @V3Localize.Detail private var text
    
    internal func body(content: Content) -> some View {
        content
            .navigationTitle(self.title)
            .onLoadChange(of: self.selection.tag) {
                self.query.id = $0
            }
    }
    
    private var title: LocalizedString {
        if let selectedTag = self.query.data {
            if let tagName = selectedTag.name {
                return tagName
            } else {
                return self.text.tagUntitled
            }
        } else {
            switch self.selection.tag?.kind ?? .user {
            case .systemUnread:
                return self.text.titleUnread
            case .systemAll:
                return self.text.titleAll
            case .user:
                return self.text.noTagSelected.title
            }
        }
    }
}
