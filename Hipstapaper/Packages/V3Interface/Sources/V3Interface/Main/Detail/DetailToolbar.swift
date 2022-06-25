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
import V3Model
import V3Store
import V3Style
import V3Localize

extension ViewModifier where Self == DetailToolbar {
    internal static var detailToolbar: Self { Self.init() }
}

internal struct DetailToolbar: ViewModifier {

    @Nav private var nav
    @Query private var query
    @V3Style.DetailToolbar private var style
    @V3Localize.DetailToolbar private var text
    
    @WebsiteSearchListQuery private var data
    @Environment(\.openURL) private var openExternal
    
    private var isSelection: Bool {
        !self.nav.detail.selectedWebsites.isEmpty
    }
    
    internal func body(content: Content) -> some View {
        content
            .onChange(of: self.nav.detail.selectedWebsites) {
                _data.search = $0
            }
            .toolbarRole(.editor)
            .toolbar(id: "detail") {
                ToolbarItem(id: "openInApp", placement: .secondaryAction) {
                    self.style.openInApp.button(self.text.openInApp, enabled: self.isSelection) {
                        
                    }
                }
                ToolbarItem(id: "openExternal", placement: .secondaryAction) {
                    self.style.openExternal.button(self.text.openExternal,
                                                   enabled: self.data.count == 1)
                    {
                        guard let url = self.data.first?.preferredURL else { return }
                        self.openExternal(url)
                    }
                }
                ToolbarItem(id: "archiveYes", placement: .secondaryAction) {
                    self.style.archiveYes.button(self.text.archiveYes, enabled: self._data.canArchiveYes) {
                        self._data.setArchive(true)
                    }
                }
                ToolbarItem(id: "archiveNo", placement: .secondaryAction) {
                    self.style.archiveNo.button(self.text.archiveNo, enabled: self._data.canArchiveNo) {
                        self._data.setArchive(false)
                    }
                }
                ToolbarItem(id: "applyTags", placement: .secondaryAction) {
                    self.style.applyTags.button(self.text.applyTags, enabled: self.isSelection) {
                        self.nav.detail.isApplyTags = self.nav.detail.selectedWebsites
                    }
                    .popover(items: self.$nav.detail.isApplyTags) { selection in
                        Text("\(selection.count) selected")
                    }
                }
                ToolbarItem(id: "share", placement: .secondaryAction) {
                    self.style.share.button(self.text.share, enabled: self.isSelection) {
                        
                    }
                }
                ToolbarItem(id: "sort", placement: .secondaryAction) {
                    self.style.sort.button(self.text.sort) {
                        
                    }
                }
                ToolbarItem(id: "filter", placement: .primaryAction) {
                    if self.query.isOnlyNotArchived {
                        self.style.filterYes.button(self.text.filter) {
                            self.query.isOnlyNotArchived = false
                        }
                    } else {
                        self.style.filterNo.button(self.text.filter) {
                            self.query.isOnlyNotArchived = true
                        }
                    }

                }
            }
    }
}
