//
//  Created by Jeffrey Bergier on 2022/07/01.
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

extension ViewModifier where Self == Toolbar {
    internal static var toolbar: Self { Self.init() }
}

internal struct Toolbar: ViewModifier {
    
    @State private var websiteURL: String = "http://www.google.com/this.is.a.super.long.url.can.you.see.it.all"
    @SizeClass private var sizeclass
    
    internal func body(content: Content) -> some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .toolbarRole(.navigationStack)
            .toolbar {
                ToolbarItem(id: .itemArchiveAndClose, placement: .primaryAction) {
                    self.itemArchiveAndClose
                }
                ToolbarItem(id: .itemClose, placement: .primaryAction) {
                    self.itemClose
                }
                switch self.sizeclass.horizontal {
                case .regular:
                    ToolbarItem(id: .itemStatus, placement: .principal) {
                        self.itemStatus
                    }
                    ToolbarItem(id: .itemBack, placement: .navigation) {
                        self.itemBack
                    }
                    ToolbarItem(id: .itemForward, placement: .navigation) {
                        self.itemForward
                    }
                    ToolbarItem(id: .itemStopReload, placement: .navigation) {
                        self.itemStopReload
                    }
                    ToolbarItem(id: .itemJavaScript, placement: .bottomBar) {
                        self.itemJavaScript
                    }
                    ToolbarItem(id: .itemSpacer1, placement: .bottomBar) {
                        self.itemSpacer
                    }
                    ToolbarItem(id: .itemOpenExternal, placement: .bottomBar) {
                        self.itemOpenExternal
                    }
                    ToolbarItem(id: .itemSeparator1, placement: .bottomBar) {
                        self.itemSeparator
                    }
                    ToolbarItem(id: .itemShare, placement: .bottomBar) {
                        self.itemShare
                    }
                case .compact:
                    ToolbarItem(id: .itemStatus, placement: .principal) {
                        self.itemStatus
                    }
                    ToolbarItem(id: .itemBack, placement: .bottomBar) {
                        self.itemBack
                    }
                    ToolbarItem(id: .itemForward, placement: .bottomBar) {
                        self.itemForward
                    }
                    ToolbarItem(id: .itemSeparator1, placement: .bottomBar) {
                        self.itemSeparator
                    }
                    ToolbarItem(id: .itemStopReload, placement: .bottomBar) {
                        self.itemStopReload
                    }
                    ToolbarItem(id: .itemJavaScript, placement: .bottomBar) {
                        self.itemJavaScript
                    }
                    ToolbarItem(id: .itemSpacer1, placement: .bottomBar) {
                        self.itemSpacer
                    }
                    ToolbarItem(id: .itemOpenExternal, placement: .bottomBar) {
                        self.itemOpenExternal
                    }
                    ToolbarItem(id: .itemSeparator2, placement: .bottomBar) {
                        self.itemSeparator
                    }
                    ToolbarItem(id: .itemShare, placement: .bottomBar) {
                        self.itemShare
                    }
                }
            }
    }
    
    private var itemBack: some View {
        Button("<") {}
    }
    
    private var itemForward: some View {
        Button(">") {}
    }
    
    private var itemLabelBackForward: some View {
        Text("Back and Forward")
    }
    
    private var itemStopReload: some View {
        Button("R") {}
    }
    
    private var itemJavaScript: some View {
        Button("JS") {}
    }
    
    private var itemStatus: some View {
        TextField("Page Title", text: self.$websiteURL)
    }
    
    private var itemOpenExternal: some View {
        Button("O") {}
    }
    
    private var itemShare: some View {
        Button("⬆") {}
    }
    
    private var itemArchiveAndClose: some View {
        Button("Archive") {}
    }
    
    private var itemClose: some View {
        Button("Close") {}
    }
    
    private var itemSpacer: some View {
        Spacer()
    }
    
    private var itemSeparator: some View {
        Text("|")
    }
}

extension String {
    fileprivate static let itemBack            = "toolbar.back"
    fileprivate static let itemForward         = "toolbar.forward"
    fileprivate static let itemBackForward     = "toolbar.backforward"
    fileprivate static let itemStopReload      = "toolbar.stopreload"
    fileprivate static let itemJavaScript      = "toolbar.javascript"
    fileprivate static let itemStatus          = "toolbar.status"
    fileprivate static let itemOpenExternal    = "toolbar.openExternal"
    fileprivate static let itemShare           = "toolbar.share"
    fileprivate static let itemArchiveAndClose = "toolbar.itemArchiveAndClose"
    fileprivate static let itemClose           = "toolbar.close"
    fileprivate static let itemSpacer1         = "toolbar.spacer1"
    fileprivate static let itemSeparator1      = "toolbar.separator1"
    fileprivate static let itemSeparator2      = "toolbar.separator2"
}
