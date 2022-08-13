//
//  Created by Jeffrey Bergier on 2022/06/23.
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
import V3Style
import V3Localize
import V3WebsiteEdit

internal struct DetailToolbar: ViewModifier {

    @Nav private var nav
    @BulkActions private var state
    
    @JSBSizeClass private var sizeClass
    @V3Style.DetailToolbar private var style
    @V3Localize.DetailToolbar private var text
    
    private func itemOpenExternal() -> some View {
        self.style.toolbar.action(text: self.text.openExternal)
            .button(item: self.state.pull.openExternal?.single)
        { _ in
            self.state.push.openExternal = self.state.pull.openExternal
        }
    }
    
    internal func body(content: Content) -> some View {
        content
            .toolbarRole(.editor)
            .toolbar(id: .barTop) {
                ToolbarItem(id: .itemOpenInApp, placement: .primaryAction) {
                    self.style.toolbar.action(text: self.text.openInApp)
                        .button(item: self.state.pull.openInApp?.single)
                    { _ in
                        self.state.push.openInApp = self.state.pull.openInApp
                    }
                }
                // TODO: Remove this switch statement when possible
                // Needed because Compact doesn't show items that are
                // marked as showsByDefault == false here
                switch self.sizeClass.horizontal {
                case .compact:
                    ToolbarItem(id: .itemOpenExternalCompact,
                                placement: .secondaryAction,
                                content: self.itemOpenExternal)
                case .regular:
                    ToolbarItem(id: .itemOpenExternalRegular,
                                placement: .secondaryAction,
                                showsByDefault: false,
                                content: self.itemOpenExternal)
                    ToolbarItem(id: .itemColumn,
                                placement: .secondaryAction,
                                showsByDefault: false,
                                content: ColumnMenu.init)
                }
                ToolbarItem(id: .itemArchiveYes, placement: .secondaryAction) {
                    self.style.toolbar.action(text: self.text.archiveYes)
                        .button(items: self.state.pull.archiveYes)
                    {
                        self.state.push.archiveYes = $0
                    }
                }
                ToolbarItem(id: .itemArchiveNo, placement: .secondaryAction) {
                    self.style.toolbar.action(text: self.text.archiveNo)
                        .button(items: self.state.pull.archiveNo)
                    {
                        self.state.push.archiveNo = $0
                    }
                }
                ToolbarItem(id: .itemTagApply, placement: .secondaryAction) {
                    self.style.tagApply.button(self.text.tagApply,
                                               enabled: self.state.pull.tagApply)
                    {
                        self.state.push.tagApply = $0
                    }
                    .modifier(WebsiteEdit.popover(self.$nav.detail.isTagApply))
                }
                ToolbarItem(id: .itemShare, placement: .secondaryAction) {
                    self.style.toolbar.action(text: self.text.share)
                        .button(items: self.state.pull.share)
                    {
                        self.state.push.share = $0
                    }
                    .modifier(ShareListPresentation())
                }
            }
            .toolbar(id: .barBottom) {
                ToolbarItem(id: .itemError, placement: .bottomSecondary) {
                    self.style.error.button(self.text.error,
                                            enabled: self.state.pull.showErrors)
                    {
                        self.state.push.showErrors = true
                    }
                    .modifier(DetailErrorListPresentation())
                }
                ToolbarItem(id: .itemSpacer1, placement: .bottomSecondary) {
                    Spacer()
                }
                if self.state.pull.deselectAll.isEmpty == false {
                    ToolbarItem(id: .itemDeselect, placement: .bottomSecondary) {
                        self.style.deselectAll.button(self.text.deselectAll,
                                                      style: .title,
                                                      enabled: self.state.pull.deselectAll)
                        {
                            self.state.push.deselectAll = $0
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    ToolbarItem(id: .itemSpacer2, placement: .bottomSecondary) {
                        Spacer()
                    }
                }
                if self.nav.sidebar.selectedTag?.isSystem == false {
                    ToolbarItem(id: .itemFilter, placement: .bottomSecondary) {
                        FilterMenu()
                    }
                }
                ToolbarItem(id: .itemSort, placement: .bottomSecondary) {
                    SortMenu()
                }
            }
            .disabled(self.nav.sidebar.selectedTag == nil)
    }
}

extension String {
    fileprivate static let barTop                  = "barTop"
    fileprivate static let itemOpenInApp           = "itemOpenInApp"
    fileprivate static let itemOpenExternalCompact = "itemOpenExternalCompact"
    fileprivate static let itemOpenExternalRegular = "itemOpenExternalRegular"
    fileprivate static let itemArchiveYes          = "itemArchiveYes"
    fileprivate static let itemArchiveNo           = "itemArchiveNo"
    fileprivate static let itemTagApply            = "itemTagApply"
    fileprivate static let itemShare               = "itemShare"
    fileprivate static let barBottom               = "barBottom"
    fileprivate static let itemError               = "itemError"
    fileprivate static let itemSpacer1             = "itemSpacer1"
    fileprivate static let itemSpacer2             = "itemSpacer2"
    fileprivate static let itemDeselect            = "itemDeselect"
    fileprivate static let itemColumn              = "itemColumn"
    fileprivate static let itemSort                = "itemSort"
    fileprivate static let itemFilter              = "itemFilter"
}

extension ToolbarItemPlacement {
    fileprivate static var bottomSecondary: ToolbarItemPlacement {
        #if os(macOS)
        .secondaryAction
        #else
        .bottomBar
        #endif
    }
}
