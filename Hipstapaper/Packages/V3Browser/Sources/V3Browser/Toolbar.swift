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
import V3Errors

internal struct Toolbar: ViewModifier {
    
    @Navigation private var nav
    @Errors private var errorQueue
    @JSBSizeClass private var sizeclass
    @V3Style.Browser private var style
    @V3Localize.Browser private var text
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    
    @Binding internal var isArchived: Bool
    internal let preferredURL: URL?
    private var sharable: [ShareList.Data] {
        return [
            self.nav.currentURL.map { ShareList.Data.current($0) },
            self.preferredURL.map { ShareList.Data.saved($0) }
        ].compactMap { $0 }
    }
    
    internal func body(content: Content) -> some View {
        content
            .navigationTitle(self.nav.currentTitle)
            .navigationBarTitleDisplayModeInline
            .toolbar {
                switch self.sizeclass.horizontal {
                case .regular:
                    // hack to stop compiler failures for too many items
                    if true { // Navigation: Top Leading
                        ToolbarItem(id: .itemBack, placement: .navigation) {
                            self.itemBack
                        }
                        ToolbarItem(id: .itemForward, placement: .navigation) {
                            self.itemForward
                        }
                        ToolbarItem(id: .itemStopReload, placement: .navigation) {
                            self.itemStopReload
                        }
                    }
                    if true { // Title: Top middle, trailing
                        ToolbarItem(id: .itemStatus, placement: .principal) {
                            self.itemStatus
                        }
                        ToolbarItem(id: .itemClose, placement: .primaryAction) {
                            self.itemClose
                        }
                        ToolbarItem(id: .itemArchiveAndClose, placement: .primaryAction) {
                            self.itemArchiveAndClose
                        }
                    }
                    ToolbarItem(id: .itemJavaScript, placement: .bottomSecondary) {
                        self.itemJavaScript
                    }
                    ToolbarItem(id: .itemSeparator1, placement: .bottomSecondary) {
                        self.itemSeparator
                    }
                    ToolbarItem(id: .itemErrors, placement: .bottomSecondary) {
                        self.itemErrors
                    }
                    ToolbarItem(id: .itemSpacer1, placement: .bottomSecondary) {
                        self.itemSpacer
                    }
                    ToolbarItem(id: .itemOpenExternal, placement: .bottomSecondary) {
                        self.itemOpenExternal
                    }
                    ToolbarItem(id: .itemSeparator2, placement: .bottomSecondary) {
                        self.itemSeparator
                    }
                    ToolbarItem(id: .itemShare, placement: .bottomSecondary) {
                        self.itemShare
                    }
                case .compact, .tiny:
                    if true { // Top Bar
                        ToolbarItem(id: .itemArchiveAndClose, placement: .cancellationAction) {
                            self.itemArchiveAndClose
                        }
                        ToolbarItem(id: .itemStatus, placement: .principal) {
                            self.itemStatus
                        }
                        ToolbarItem(id: .itemClose, placement: .primaryAction) {
                            self.itemClose
                        }
                    }
                    if true { // Navigation: Bottom Leading
                        ToolbarItem(id: .itemBack, placement: .bottomFatal) {
                            self.itemBack
                        }
                        ToolbarItem(id: .itemForward, placement: .bottomFatal) {
                            self.itemForward
                        }
                        ToolbarItem(id: .itemSeparator1, placement: .bottomFatal) {
                            self.itemSeparator
                        }
                        ToolbarItem(id: .itemStopReload, placement: .bottomFatal) {
                            self.itemStopReload
                        }
                    }
                    ToolbarItem(id: .itemSpacer1, placement: .bottomFatal) {
                        self.itemSpacer
                    }
                    if true { // Bottom Middle
                        ToolbarItem(id: .itemJavaScript, placement: .bottomFatal) {
                            self.itemJavaScript
                        }
                        ToolbarItem(id: .itemSeparator2, placement: .bottomFatal) {
                            self.itemSeparator
                        }
                        ToolbarItem(id: .itemErrors, placement: .bottomFatal) {
                            self.itemErrors
                        }
                        ToolbarItem(id: .itemSpacer2, placement: .bottomFatal) {
                            self.itemSpacer
                        }
                    }
                    if true { // Bottom trailing
                        ToolbarItem(id: .itemOpenExternal, placement: .bottomFatal) {
                            self.itemOpenExternal
                        }
                        ToolbarItem(id: .itemSeparator3, placement: .bottomFatal) {
                            self.itemSeparator
                        }
                        ToolbarItem(id: .itemShare, placement: .bottomFatal) {
                            self.itemShare
                        }
                    }
                }
            }
    }
    
    private var itemBack: some View {
        self.style.toolbar
                  .action(text: self.text.back)
                  .button(isEnabled: self.nav.canGoBack)
        {
            self.nav.shouldGoBack = true
        }
    }
    
    private var itemForward: some View {
        self.style.toolbar
                  .action(text: self.text.forward)
                  .button(isEnabled: self.nav.canGoForward)
        {
            self.nav.shouldGoForward = true
        }
    }
    
    private var itemStopReload: some View {
        if self.nav.isLoading {
            return self.style.toolbar.action(text: self.text.stop).button {
                self.nav.shouldStop = true
            }
        } else {
            return self.style.toolbar.action(text: self.text.reload).button {
                self.nav.shouldReload = true
            }
        }
    }
    
    private var itemJavaScript: some View {
        if self.nav.isJSEnabled {
            return self.style.toolbar.action(text: self.text.jsYes).button {
                self.nav.isJSEnabled = false
            }
        } else {
            return self.style.toolbar.action(text: self.text.jsNo).button {
                self.nav.isJSEnabled = true
            }
        }
    }
    
    private var itemStatus: some View {
        self.style.address(value: self.nav.currentTitle,
                           placeholder: self.text.loading)
    }
    
    private var itemOpenExternal: some View {
        let urlToOpen = self.nav.currentURL ?? self.nav.shouldLoadURL
        return self.style.toolbar
                         .action(text: self.text.openExternal)
                         .button(item: urlToOpen)
        {
            self.openURL($0)
        }
    }
    
    private var itemShare: some View {
        self.style.toolbar
            .action(text: self.text.share)
            .button(items: self.sharable)
        {
            self.nav.isShareList = $0
        }
        .modifier(ShareListPresentation())
    }
    
    private var itemArchiveAndClose: some View {
        self.style.toolbar
                  .action(text: self.text.archiveYes)
                  .button(isEnabled: !self.isArchived)
        {
            self.isArchived = true
            guard self.nav.isPresenting == false else { return }
            self.dismiss()
        }
    }
    
    @ViewBuilder private var itemErrors: some View {
        self.style.toolbar
            .action(text: self.text.error)
            .button(items: self.errorQueue)
        { _ in
            self.nav.isErrorList.isPresented = true
        }
        .modifier(ErrorListPresentation())
    }
    
    private var itemClose: some View {
        self.style.done.action(text: self.text.done).button {
            self.dismiss()
        }
    }
    
    private var itemSpacer: some View {
        Spacer()
    }
    
    private var itemSeparator: some View {
        self.style.separator
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
    fileprivate static let itemSpacer2         = "toolbar.spacer2"
    fileprivate static let itemSeparator1      = "toolbar.separator1"
    fileprivate static let itemSeparator2      = "toolbar.separator2"
    fileprivate static let itemSeparator3      = "toolbar.separator3"
}

extension ToolbarItemPlacement {
    fileprivate static var bottomFatal: ToolbarItemPlacement {
        #if os(macOS)
        fatalError()
        #else
        .bottomBar
        #endif
    }
    fileprivate static var bottomSecondary: ToolbarItemPlacement {
        #if os(macOS)
        .secondaryAction
        #else
        .bottomBar
        #endif
    }
}
