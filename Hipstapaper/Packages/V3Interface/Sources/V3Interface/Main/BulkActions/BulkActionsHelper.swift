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
    
    @Nav private var nav
    @Controller private var controller
    @BulkActions private var state
    @BulkActionsQuery private var data
    @Environment(\.openURL) private var openExternal
    @Environment(\.codableErrorResponder) private var errorResponder
    
    internal func body(content: Content) -> some View {
        content
        // MARK: Update PULL State
            .onLoadChange(of: self.nav.sidebar.selectedTag) { newValue in
                _data.setTag(selection: newValue.map { [$0] } ?? [])
            }
            .onLoadChange(of: self.nav.detail.selectedWebsites) { newValue in
                _data.setWebsite(selection: newValue)
            }
            .onLoadChange(of: self.nav.errorQueue) { newValue in
                self.data.showErrors = !newValue.isEmpty
            }
            .onLoadChange(of: self.data) { newState in
                self.state.pull = newState
            }
        // MARK: Act on PUSH state
            .onChange(of: self.state.push.websiteAdd) { newValue in
                guard newValue else { return }
                defer { self.state.push.websiteAdd = false }
                switch self.controller.createWebsite() {
                case .success(let identifier):
                    self.nav.isWebsitesEdit = [identifier]
                case .failure(let error):
                    NSLog(String(describing: error))
                    self.errorResponder(.init(error as NSError))
                }
            }
            .onChange(of: self.state.push.tagAdd) { newValue in
                guard newValue else { return }
                defer { self.state.push.tagAdd = false }
                switch self.controller.createTag() {
                case .success(let identifier):
                    self.nav.sidebar.isTagsEdit.editing = [identifier]
                case .failure(let error):
                    NSLog(String(describing: error))
                    self.errorResponder(.init(error as NSError))
                }
            }
            .onChange(of: self.state.push.openInApp) { newValue in
                guard let newValue else { return }
                defer { self.state.push.openInApp = nil }
                self.nav.detail.isBrowse = newValue.single
            }
            .onChange(of: self.state.push.openExternal) { newValue in
                guard let newValue else { return }
                defer { self.state.push.openExternal = nil }
                newValue.single.map { self.openExternal($0) }
            }
            .onChange(of: self.state.push.share) { selection in
                guard selection.isEmpty == false else { return }
                defer { self.state.push.share = [] }
                // TODO: Share
            }
            .onChange(of: self.state.push.archiveYes) { selection in
                guard selection.isEmpty == false else { return }
                defer {
                    self.state.push.archiveYes = []
                    self.nav.detail.selectedWebsites = []
                }
                guard let error = BulkActionsQuery.setArchive(true, selection, self.controller).error else { return }
                self.errorResponder(.init(error as NSError))
            }
            .onChange(of: self.state.push.archiveNo) { selection in
                guard selection.isEmpty == false else { return }
                defer {
                    self.state.push.archiveNo = []
                    self.nav.detail.selectedWebsites = []
                }
                guard let error = BulkActionsQuery.setArchive(false, selection, self.controller).error else { return }
                self.errorResponder(.init(error as NSError))
            }
            .onChange(of: self.state.push.tagApply) { selection in
                guard selection.isEmpty == false else { return }
                defer {
                    self.state.push.tagApply = []
                    self.nav.detail.selectedWebsites = []
                }
                self.nav.detail.isTagApply = selection
            }
            .onChange(of: self.state.push.websiteEdit) { selection in
                guard selection.isEmpty == false else { return }
                defer {
                    self.state.push.websiteEdit = []
                    self.nav.detail.selectedWebsites = []
                }
                self.nav.isWebsitesEdit = selection
            }
            .onChange(of: self.state.push.tagsEdit) { selection in
                guard selection.isEmpty == false else { return }
                defer { self.state.push.tagsEdit = [] }
                self.nav.sidebar.isTagsEdit.editing = selection
            }
            .onChange(of: self.state.push.websiteDelete) { selection in
                guard selection.isEmpty == false else { return }
                defer {
                    self.state.push.websiteDelete = []
                    self.nav.detail.selectedWebsites = []
                }
                self.errorResponder(DeleteWebsiteError(selection).codableValue)
            }
            .onChange(of: self.state.push.tagDelete) { selection in
                guard selection.isEmpty == false else { return }
                defer {
                    self.state.push.tagDelete = []
                    self.nav.sidebar.selectedTag = .default
                }
                self.errorResponder(DeleteTagError(selection).codableValue)
            }
            .onChange(of: self.state.push.showErrors) { newValue in
                guard newValue else { return }
                defer { self.state.push.showErrors = false }
                self.nav.detail.isErrorList.isPresented = true
            }
    }
}
