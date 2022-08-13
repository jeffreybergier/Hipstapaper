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
import V3Errors

internal struct DetailMenu: ViewModifier {

    @BulkActions private var state
    @Controller private var controller
    
    @V3Style.DetailToolbar private var style
    @V3Localize.DetailToolbar private var text

    internal func body(content: Content) -> some View {
        content
            .contextMenu(forSelectionType: Website.Selection.Element.self) {
                $0.view { items in
                    self.text.openInApp
                        .action(with: self.style.toolbar)
                        .button(item: BulkActionsQuery.openWebsite(items, self.controller)?.single)
                    {
                        self.state.push.openInApp = .single($0)
                    }
                    self.style.openExternal.button(self.text.openExternal,
                                                   enabled: BulkActionsQuery.openURL(items, self.controller)?.single)
                    {
                        self.state.push.openExternal = .single($0)
                    }
                    self.style.archiveYes.button(self.text.archiveYes,
                                                 enabled: BulkActionsQuery.canArchiveYes(items, self.controller))
                    {
                        self.state.push.archiveYes = $0
                    }
                    self.style.archiveNo.button(self.text.archiveNo,
                                                enabled: BulkActionsQuery.canArchiveNo(items, self.controller))
                    {
                        self.state.push.archiveNo = $0
                    }
                    self.style.share.button(self.text.share) {
                        self.state.push.share = items
                    }
                    self.style.tagApply.button(self.text.tagApply) {
                        self.state.push.tagApply = items
                    }
                    self.style.edit.button(self.text.edit) {
                        self.state.push.websiteEdit = items
                    }
                    self.style.delete.button(self.text.delete, role: .destructive) {
                        self.state.push.websiteDelete = items
                    }
                } onEmpty: {
                    EmptyView()
                }
            }
    }
}
