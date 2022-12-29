//
//  Created by Jeffrey Bergier on 2022/07/22.
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
import V3Errors

internal struct BulkActionsHelper: ViewModifier {
    
    @Navigation private var nav
    @Selection private var selection
    @Errors private var errorQueue
    @Controller private var controller
    @BulkActions private var appState
    @BulkActionsQuery private var storeState
    @Environment(\.openURL) private var openExternal
    @Environment(\.openWindow) private var openWindow
    @Environment(\.supportsMultipleWindows) private var supportsMultipleWindows
    @Environment(\.errorResponder) private var errorResponder
    
    internal func body(content: Content) -> some View {
        content
        // MARK: Update PULL State
            .onLoadChange(of: self.selection.tag) { newValue in
                _storeState.setTag(selection: newValue.map { [$0] } ?? [])
            }
            .onLoadChange(of: self.selection.websites) { newValue in
                _storeState.setWebsite(selection: newValue)
            }
            .onLoadChange(of: self.errorQueue) { newValue in
                self.storeState.showErrors = !newValue.isEmpty
            }
            .onLoadChange(of: self.storeState) { newState in
                self.appState.pull = newState
            }
        // MARK: Act on PUSH state
            .onChange(of: self.appState.push.websiteAdd) { newValue in
                guard newValue else { return }
                defer { self.appState.push.websiteAdd = false }
                switch self.controller.createWebsite() {
                case .success(let identifier):
                    self.nav.isWebsitesEdit = [identifier]
                case .failure(let error):
                    NSLog(String(describing: error))
                    // TODO: Errors, yuck. So much to do
                    // self.errorResponder(.init(error))
                }
            }
            .onChange(of: self.appState.push.tagAdd) { newValue in
                guard newValue else { return }
                defer { self.appState.push.tagAdd = false }
                switch self.controller.createTag() {
                case .success(let identifier):
                    self.nav.sidebar.isTagsEdit.isPresented = [identifier]
                case .failure(let error):
                    NSLog(String(describing: error))
                    // TODO: Errors, yuck. So much to do
                    // self.errorResponder(.init(error))
                }
            }
            .onChange(of: self.appState.push.openInSheet) { newValue in
                defer { self.appState.push.openInWindow = nil }
                guard let newValue else { return }
                #if os(macOS)
                newValue.multi.forEach { self.openWindow(value: $0) }
                #else
                self.nav.detail.isBrowse = newValue.single
                #endif
            }
            .onChange(of: self.appState.push.openInWindow) { newValue in
                defer { self.appState.push.openInWindow = nil }
                guard let newValue else { return }
                if self.supportsMultipleWindows {
                    newValue.multi.forEach { self.openWindow(value: $0) }
                } else {
                    self.nav.detail.isBrowse = newValue.single
                }
            }
            .onChange(of: self.appState.push.openExternal) { newValue in
                guard let newValue else { return }
                defer { self.appState.push.openExternal = nil }
                newValue.multi.forEach { self.openExternal($0) }
            }
            .onChange(of: self.appState.push.share) { selection in
                guard selection.isEmpty == false else { return }
                defer { self.appState.push.share = [] }
                self.nav.detail.isShare = selection
            }
            .onChange(of: self.appState.push.archiveYes) { selection in
                guard selection.isEmpty == false else { return }
                defer { self.appState.push.archiveYes = [] }
                guard let error = BulkActionsQuery.setArchive(true, selection, self.controller).error else { return }
                // TODO: Errors, yuck. So much to do
                // self.errorResponder(.init(error))
            }
            .onChange(of: self.appState.push.archiveNo) { selection in
                guard selection.isEmpty == false else { return }
                defer { self.appState.push.archiveNo = [] }
                guard let error = BulkActionsQuery.setArchive(false, selection, self.controller).error else { return }
                // TODO: Errors, yuck. So much to do
                // self.errorResponder(.init(error))
            }
            .onChange(of: self.appState.push.tagApply) { selection in
                guard selection.isEmpty == false else { return }
                defer { self.appState.push.tagApply = [] }
                self.nav.detail.isTagApply = selection
            }
            .onChange(of: self.appState.push.websiteEdit) { selection in
                guard selection.isEmpty == false else { return }
                defer { self.appState.push.websiteEdit = [] }
                self.nav.isWebsitesEdit = selection
            }
            .onChange(of: self.appState.push.tagsEdit) { selection in
                guard selection.isEmpty == false else { return }
                defer { self.appState.push.tagsEdit = [] }
                self.nav.sidebar.isTagsEdit.isPresented = selection
            }
            .onChange(of: self.appState.push.websiteDelete) { selection in
                guard selection.isEmpty == false else { return }
                defer { self.appState.push.websiteDelete = [] }
                self.errorResponder(DeleteRequestError.website(selection))
            }
            .onChange(of: self.appState.push.tagDelete) { selection in
                guard selection.isEmpty == false else { return }
                defer { self.appState.push.tagDelete = [] }
                self.errorResponder(DeleteRequestError.tag(selection))
            }
            .onChange(of: self.appState.push.showErrors) { newValue in
                guard newValue else { return }
                defer { self.appState.push.showErrors = false }
                self.nav.detail.isErrorList.isPresented = true
            }
            .onChange(of: self.appState.push.deselectAll) { newValue in
                guard newValue.isEmpty == false else { return }
                defer { self.appState.push.deselectAll = [] }
                self.selection.websites = []
            }
    }
}
