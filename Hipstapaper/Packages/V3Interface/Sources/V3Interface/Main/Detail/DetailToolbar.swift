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
import V3Errors

internal struct DetailToolbar: ViewModifier {
    
    @Navigation private var nav
    @Selection private var selection
    @BulkActions private var state
    @Errors private var errorQueue
    
    @JSBSizeClass private var sizeClass
    @HACK_EditMode private var isEditMode
    
    @V3Style.DetailToolbar private var style
    @V3Localize.DetailToolbar private var text
    
    internal func body(content: Content) -> some View {
        content
            .toolbarRole(.editor)
            .toolbar(id: .barTop, content: self.barTopAll)
            .toolbar(id: .barBottom) {
                switch self.isEditMode {
                case true: self.barBottomMulti()
                case false: self.barBottomSingle()
                }
            }
            .disabled(self.selection.tag == nil)
    }
    
    #if os(macOS)
    
    @ToolbarContentBuilder internal func barTopAll() -> some CustomizableToolbarContent {
        ToolbarItem(id: .itemSort,
                    placement: .automatic,
                    showsByDefault: true)
        {
            SortMenu()
        }
        ToolbarItem(id: .itemFilter,
                    placement: .automatic,
                    showsByDefault: true)
        {
            FilterMenu()
                .disabled(self.selection.tag?.isSystem ?? false)
        }
        ToolbarItem(id: .itemColumn,
                    placement: .automatic,
                    showsByDefault: false,
                    content: ColumnMenu.init)
        ToolbarItem(id: .itemError, placement: .automatic) {
            self.style.toolbar.action(text: self.text.error)
                .button(isEnabled: self.state.pull.showErrors)
            {
                self.state.push.showErrors = true
            }
            .modifier(DetailErrorListPresentation())
        }
    }
    
    @ToolbarContentBuilder internal func barBottomSingle() -> some CustomizableToolbarContent {
        ToolbarItem(id: .barEmpty) { EmptyView() }
    }
    
    @ToolbarContentBuilder internal func barBottomMulti() -> some CustomizableToolbarContent {
        ToolbarItem(id: .barEmpty) { EmptyView() }
    }
    
    #else
    
    @ToolbarContentBuilder internal func barTopAll() -> some CustomizableToolbarContent {
        ToolbarItem(id: .itemEditButton,
                    placement: .primaryAction)
        {
            HACK_EditButton()
        }
        ToolbarItem(id: .itemSort,
                    placement: .secondaryAction,
                    showsByDefault: true)
        {
            SortMenu()
        }
        ToolbarItem(id: .itemFilter,
                    placement: .secondaryAction,
                    showsByDefault: true)
        {
            FilterMenu()
                .disabled(self.selection.tag?.isSystem ?? false)
        }
        ToolbarItem(id: .itemColumn,
                    placement: .secondaryAction,
                    showsByDefault: false,
                    content: ColumnMenu.init)
        if self.errorQueue.isEmpty == false {
            ToolbarItem(id: .itemError, placement: .navigation) {
                self.style.toolbar.action(text: self.text.error)
                    .button(isEnabled: self.state.pull.showErrors)
                {
                    self.state.push.showErrors = true
                }
                .modifier(DetailErrorListPresentation())
            }
        }
    }
    
    @ToolbarContentBuilder internal func barBottomSingle() -> some CustomizableToolbarContent {
        ToolbarItem(id: .barEmpty) { EmptyView() }
    }
    
    @ToolbarContentBuilder internal func barBottomMulti() -> some CustomizableToolbarContent {
        ToolbarItem(id: .itemOpenExternal, placement: .bottomBar) {
            self.style.toolbar.action(text: self.text.openExternal)
                .button(item: self.state.pull.openExternal?.single)
            { _ in
                self.state.push.openExternal = self.state.pull.openExternal
            }
        }
        ToolbarItem(id: .itemSpacer1, placement: .bottomBar) {
            Spacer()
        }
        ToolbarItem(id: .itemArchiveYes, placement: .bottomBar) {
            self.style.toolbar.action(text: self.text.archiveYes)
                .button(items: self.state.pull.archiveYes)
            {
                self.state.push.archiveYes = $0
            }
        }
        ToolbarItem(id: .itemArchiveNo, placement: .bottomBar) {
            self.style.toolbar.action(text: self.text.archiveNo)
                .button(items: self.state.pull.archiveNo)
            {
                self.state.push.archiveNo = $0
            }
        }
        ToolbarItem(id: .itemTagApply, placement: .bottomBar) {
            self.style.toolbar.action(text: self.text.tagApply)
                .button(items: self.state.pull.tagApply)
            {
                self.nav.detail.isTagApplyPopover = $0
            }
            .modifier(WebsiteEditPopover(self.$nav.detail.isTagApplyPopover, start: .tag))
        }
        ToolbarItem(id: .itemSpacer2, placement: .bottomBar) {
            Spacer()
        }
        ToolbarItem(id: .itemShare, placement: .bottomBar) {
            self.style.toolbar.action(text: self.text.share)
                .button(items: self.state.pull.share)
            {
                self.nav.detail.isSharePopover = $0
            }
            .modifier(ShareListPopover(self.$nav.detail.isSharePopover))
        }
    }
    
    #endif
}

extension String {
    fileprivate static let barTop                  = "barTop"
    fileprivate static let barBottom               = "barBottom"
    fileprivate static let barEmpty                = "barEmpty"
    fileprivate static let itemOpenExternal        = "itemOpenExternal"
    fileprivate static let itemArchiveYes          = "itemArchiveYes"
    fileprivate static let itemArchiveNo           = "itemArchiveNo"
    fileprivate static let itemTagApply            = "itemTagApply"
    fileprivate static let itemShare               = "itemShare"
    fileprivate static let itemError               = "itemError"
    fileprivate static let itemSpacer1             = "itemSpacer1"
    fileprivate static let itemSpacer2             = "itemSpacer2"
    fileprivate static let itemColumn              = "itemColumn"
    fileprivate static let itemSort                = "itemSort"
    fileprivate static let itemFilter              = "itemFilter"
    fileprivate static let itemEditButton          = "itemEditButton"
}
