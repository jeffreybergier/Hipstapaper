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
import V3Model
import V3Store
import V3Errors

internal struct BulkActionsHelper: ViewModifier {
    
    @Navigation       private var nav
    @Selection        private var selection
    @Controller       private var controller
    @ErrorStorage     private var errors
    @BulkActions      private var appState
    @BulkActionsQuery private var storeState
    @Environment(\.openURL) private var openExternal
    @Environment(\.openWindow) private var openWindow
    @Environment(\.supportsMultipleWindows) private var supportsMultipleWindows
    
    internal func body(content: Content) -> some View {
        content
        // MARK: Update PULL State
            .onChange(of: self.selection.tag, initial: true) { _, newValue in
                _storeState.setTag(selection: newValue.map { [$0] } ?? [])
            }
            .onChange(of: self.selection.websites, initial: true) { _, newValue in
                _storeState.setWebsite(selection: newValue)
            }
            .onChange(of: self.storeState, initial: true) { _, newValue in
                self.appState.pull = newValue
            }
            // TODO: Check that error handling still works
            .onReceive(self.errors.didAppendPub) { _ in
                self.storeState.showErrors = true
            }
        // MARK: Act on PUSH state
            .onChange(of: self.appState.push.websiteAdd, initial: false) { _, newValue in
                guard newValue else { return }
                defer { self.appState.push.websiteAdd = false }
                switch self.controller.createWebsite() {
                case .success(let identifier):
                    self.nav.isWebsitesEdit = [identifier]
                case .failure(let error):
                    NSLog(String(describing: error))
                    self.errors.append(error)
                }
            }
            .onChange(of: self.appState.push.tagAdd, initial: false) { _, newValue in
                guard newValue else { return }
                defer { self.appState.push.tagAdd = false }
                switch self.controller.createTag() {
                case .success(let identifier):
                    self.nav.sidebar.isTagsEdit.isPresented = [identifier]
                case .failure(let error):
                    NSLog(String(describing: error))
                    self.errors.append(error)
                }
            }
            .onChange(of: self.appState.push.openInSheet, initial: false) { _, newValue in
                defer { self.appState.push.openInWindow = nil }
                guard let newValue else { return }
                #if os(macOS)
                newValue.multi.forEach { self.openWindow(value: $0) }
                #else
                self.nav.detail.isBrowse = newValue.single
                #endif
            }
            .onChange(of: self.appState.push.openInWindow, initial: false) { _, newValue in
                defer { self.appState.push.openInWindow = nil }
                guard let newValue else { return }
                if self.supportsMultipleWindows {
                    newValue.multi.forEach { self.openWindow(value: $0) }
                } else {
                    self.nav.detail.isBrowse = newValue.single
                }
            }
            .onChange(of: self.appState.push.openExternal, initial: false) { _, newValue in
                guard let newValue else { return }
                defer { self.appState.push.openExternal = nil }
                newValue.multi.forEach { self.openExternal($0) }
            }
            .onChange(of: self.appState.push.share, initial: false) { _, selection in
                guard selection.isEmpty == false else { return }
                defer { self.appState.push.share = [] }
                self.nav.detail.isShare = selection
            }
            .onChange(of: self.appState.push.archiveYes, initial: false) { _, selection in
                guard selection.isEmpty == false else { return }
                defer { self.appState.push.archiveYes = [] }
                guard let error = BulkActionsQuery.setArchive(true, selection, self.controller).error else { return }
                self.errors.append(error)
            }
            .onChange(of: self.appState.push.archiveNo, initial: false) { _, selection in
                guard selection.isEmpty == false else { return }
                defer { self.appState.push.archiveNo = [] }
                guard let error = BulkActionsQuery.setArchive(false, selection, self.controller).error else { return }
                self.errors.append(error)
            }
            .onChange(of: self.appState.push.tagApply, initial: false) { _, selection in
                guard selection.isEmpty == false else { return }
                defer { self.appState.push.tagApply = [] }
                self.nav.detail.isTagApply = selection
            }
            .onChange(of: self.appState.push.QRCode, initial: false) { _, selection in
                guard selection.isEmpty == false else { return }
                defer { self.appState.push.QRCode = [] }
                self.nav.detail.isQRCodePopover = selection
            }
            .onChange(of: self.appState.push.websiteEdit, initial: false) { _, selection in
                guard selection.isEmpty == false else { return }
                defer { self.appState.push.websiteEdit = [] }
                self.nav.isWebsitesEdit = selection
            }
            .onChange(of: self.appState.push.tagsEdit, initial: false) { _, selection in
                guard selection.isEmpty == false else { return }
                defer { self.appState.push.tagsEdit = [] }
                self.nav.sidebar.isTagsEdit.isPresented = selection
            }
            .onChange(of: self.appState.push.websiteDelete, initial: false) { _, selection in
                guard selection.isEmpty == false else { return }
                defer { self.appState.push.websiteDelete = [] }
                let error = DeleteWebsiteConfirmationError(selection) { selection in
                    self.controller.delete(selection)
                        .error
                        .map(self.errors.append(_:))
                }
                self.errors.append(error)
            }
            .onChange(of: self.appState.push.tagDelete, initial: false) { _, selection in
                guard selection.isEmpty == false else { return }
                defer { self.appState.push.tagDelete = [] }
                let error = DeleteTagConfirmationError(selection) { selection in
                    self.controller.delete(selection)
                        .error
                        .map(self.errors.append(_:))
                }
                self.errors.append(error)
            }
            .onChange(of: self.appState.push.showErrors, initial: false) { _, _ in
                self.nav.isError = self.errors.nextError
            }
            .onChange(of: self.appState.push.deselectAll, initial: false) { _, newValue in
                guard newValue.isEmpty == false else { return }
                defer { self.appState.push.deselectAll = [] }
                self.selection.websites = []
            }
    }
}
