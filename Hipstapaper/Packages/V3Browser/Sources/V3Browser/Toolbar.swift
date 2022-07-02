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
import V3Style
import V3Localize

internal struct Toolbar: ViewModifier {
    
    @Nav private var nav
    @SizeClass private var sizeclass
    @V3Style.Browser private var style
    @V3Localize.Browser private var text
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    
    internal var isArchived: Binding<Bool>?
    
    internal func body(content: Content) -> some View {
        content
            .navigationTitle(self.nav.currentTitle)
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
                    ToolbarItem(id: .itemErrors, placement: .navigation) {
                        self.itemErrors
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
                    if true { // hack to stop compiler failures for too many items
                        ToolbarItem(id: .itemErrors, placement: .cancellationAction) {
                            self.itemErrors
                        }
                        ToolbarItem(id: .itemStatus, placement: .principal) {
                            self.itemStatus
                        }
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
        self.style.back.button(self.text.back, enabled: self.nav.canGoBack) {
            self.nav.shouldGoBack = true
        }
    }
    
    private var itemForward: some View {
        self.style.forward.button(self.text.forward,
                                  enabled: self.nav.canGoForward)
        {
            self.nav.shouldGoForward = true
        }
    }
    
    private var itemStopReload: some View {
        if self.nav.isLoading {
            return self.style.stop.button(self.text.stop) {
                self.nav.shouldStop = true
            }
        } else {
            return self.style.reload.button(self.text.reload) {
                self.nav.shouldReload = true
            }
        }
    }
    
    private var itemJavaScript: some View {
        if self.nav.isJSEnabled {
            return self.style.jsYes.button(self.text.jsYes) {
                self.nav.isJSEnabled = false
            }
        } else {
            return self.style.jsNo.button(self.text.jsNo) {
                self.nav.isJSEnabled = true
            }
        }
    }
    
    private var itemStatus: some View {
        TextField(self.text.loading, text: self.$nav.currentTitle)
            .disabled(true)
    }
    
    private var itemOpenExternal: some View {
        let urlToOpen = self.nav.currentURL ?? self.nav.shouldLoadURL
        return self.style.openExternal.button(self.text.openExternal,
                                              enabled: urlToOpen != nil)
        {
            guard let urlToOpen else { return }
            self.openURL(urlToOpen)
        }
    }
    
    private var itemShare: some View {
        self.style.share.button(self.text.share) {
            
        }
    }
    
    private var itemArchiveAndClose: some View {
        self.style.archiveYes.button(self.text.archiveYes,
                                     enabled: self.isArchived?.wrappedValue == false)
        {
            self.isArchived?.wrappedValue = true
            self.dismiss()
        }
    }
    
    @ViewBuilder private var itemErrors: some View {
        if self.nav.errorQueue.isEmpty == false {
            self.style.error.button(self.text.error) {
                self.nav.isErrorList.isPresented = true
            }
            .modifier(ErrorListPresentation())
        }
    }
    
    private var itemClose: some View {
        Button(self.text.done) {
            self.dismiss()
        }
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
    fileprivate static let itemErrors          = "toolbar.errors"
    fileprivate static let itemSpacer1         = "toolbar.spacer1"
    fileprivate static let itemSeparator1      = "toolbar.separator1"
    fileprivate static let itemSeparator2      = "toolbar.separator2"
}

extension ViewModifier where Self == Toolbar {
    internal static var toolbar: Self { Self.init() }
}