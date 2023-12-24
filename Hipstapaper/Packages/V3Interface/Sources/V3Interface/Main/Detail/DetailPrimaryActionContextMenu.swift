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

internal struct DetailPrimaryActionContextMenu: ViewModifier {

    @BulkActions private var state
    @Controller private var controller
    
    @V3Style.DetailToolbar private var style
    @V3Localize.DetailToolbar private var text
    
    internal func body(content: Content) -> some View {
        content
            .contextMenu(forSelectionType: Website.Identifier.RawIdentifier.self) {
                $0.view { items in
                    self.style.toolbar
                        .action(text: self.text.openInWindow)
                        .button(item: self.HACK_openInWindow(items.map(Website.Identifier.init(_:))))
                    {
                        self.state.push.openInWindow = $0
                    }
                    self.style.toolbar
                        .action(text: self.text.openExternal)
                        .button(item: self.HACK_openExternal(items.map(Website.Identifier.init(_:))))
                    {
                        self.state.push.openExternal = $0
                    }
                    self.style.toolbar
                        .action(text: self.text.archiveYes)
                        .button(items: BulkActionsQuery.canArchiveYes(items.map(Website.Identifier.init(_:)), self.controller))
                    {
                        self.state.push.archiveYes = $0
                    }
                    self.style.toolbar
                        .action(text: self.text.archiveNo)
                        .button(items: BulkActionsQuery.canArchiveNo(items.map(Website.Identifier.init(_:)), self.controller))
                    {
                        self.state.push.archiveNo = $0
                    }
                    self.style.toolbar
                        .action(text: self.text.share)
                        .button(item: BulkActionsQuery.openWebsite(items.map(Website.Identifier.init(_:)), self.controller))
                    {
                        self.state.push.share = $0.multi
                    }
                    self.style.toolbar
                        .action(text: self.text.tagApply).button(items: items.map(Website.Identifier.init(_:)))
                    {
                        self.state.push.tagApply = $0
                    }
                    self.style.toolbar
                        .action(text: self.text.edit)
                        .button
                    {
                        self.state.push.websiteEdit = items.map(Website.Identifier.init(_:))
                    }
                    self.style.destructive
                        .action(text: self.text.delete)
                        .button
                    {
                        self.state.push.websiteDelete = items.map(Website.Identifier.init(_:))
                    }
                } onEmpty: {
                    EmptyView()
                }
            } primaryAction: { items in
                guard items.isEmpty == false else { return }
                self.state.push.openInSheet = .multi(items.map(Website.Identifier.init(_:)))
            }
    }
    
    private func HACK_openInWindow(_ items: Website.Selection) -> SingleMulti<Website.Selection.Element>? {
        guard let value = BulkActionsQuery.openWebsite(items, self.controller) else { return nil }
        #if os(macOS)
        return value
        #else
        guard value.multi.count == 1 else { return nil }
        return value
        #endif
    }
    
    private func HACK_openExternal(_ items: Website.Selection) -> SingleMulti<URL>? {
        guard let value = BulkActionsQuery.openURL(items, self.controller) else { return nil }
        #if os(macOS)
        return value
        #else
        guard value.multi.count == 1 else { return nil }
        return value
        #endif
    }
}

// TODO: Move to umbrella
extension Set {
    public func map<Transformed>(_ transform: (Element) -> Transformed) -> Set<Transformed> {
        let transformed: [Transformed] = self.map(transform)
        return Set<Transformed>(transformed)
    }
}
