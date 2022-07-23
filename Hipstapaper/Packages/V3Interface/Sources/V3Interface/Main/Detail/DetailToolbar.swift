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
import V3Store
import V3Style
import V3Localize
import V3WebsiteEdit

internal struct DetailToolbar: ViewModifier {

    @Nav private var nav
    @Query private var query
    @BulkActions private var state
    
    @V3Style.DetailToolbar private var style
    @V3Localize.DetailToolbar private var text
        
    internal func body(content: Content) -> some View {
        content
            .toolbarRole(.editor)
            .toolbar(id: .barTop) {
                ToolbarItem(id: .itemOpenInApp, placement: .primaryAction) {
                    self.style.openInApp.button(self.text.openInApp,
                                                enabled: self.state.pull.openInApp?.single)
                    { _ in
                        self.state.push.openInApp = self.state.pull.openInApp
                    }
                }
                ToolbarItem(id: .itemOpenExternal, placement: .secondaryAction) {
                    self.style.openExternal.button(self.text.openExternal,
                                                   enabled: self.state.pull.openExternal?.single)
                    { _ in
                        self.state.push.openExternal = self.state.pull.openExternal
                    }
                }
                ToolbarItem(id: .itemArchiveYes, placement: .secondaryAction) {
                    self.style.archiveYes.button(self.text.archiveYes,
                                                 enabled: self.state.pull.archiveYes)
                    {
                        self.state.push.archiveYes = $0
                    }
                }
                ToolbarItem(id: .itemArchiveNo, placement: .secondaryAction) {
                    self.style.archiveNo.button(self.text.archiveNo,
                                                enabled: self.state.pull.archiveNo)
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
                    self.style.share.button(self.text.share,
                                            enabled: self.state.pull.share)
                    {
                        self.state.push.share = $0
                    }
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
                ToolbarItem(id: .itemSpacer, placement: .bottomSecondary) {
                    Spacer()
                }
                ToolbarItem(id: .itemSort, placement: .bottomSecondary) {
                    SortMenu()
                }
                ToolbarItem(id: .itemFilter, placement: .bottomSecondary) {
                    FilterMenu()
                }
            }
    }
}

extension String {
    fileprivate static let barTop           = "barTop"
    fileprivate static let itemOpenInApp    = "itemOpenInApp"
    fileprivate static let itemOpenExternal = "itemOpenExternal"
    fileprivate static let itemArchiveYes   = "itemArchiveYes"
    fileprivate static let itemArchiveNo    = "itemArchiveNo"
    fileprivate static let itemTagApply     = "itemTagApply"
    fileprivate static let itemShare        = "itemShare"
    fileprivate static let barBottom        = "barBottom"
    fileprivate static let itemError        = "itemError"
    fileprivate static let itemSpacer       = "itemSpacer"
    fileprivate static let itemSort         = "itemSort"
    fileprivate static let itemFilter       = "itemFilter"
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
