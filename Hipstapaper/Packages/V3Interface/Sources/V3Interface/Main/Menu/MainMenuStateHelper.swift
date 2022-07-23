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

internal struct MainMenuStateHelper: ViewModifier {
    
    @Nav private var nav
    @Controller private var controller
    @MainMenuState private var state
    @Environment(\.openURL) private var openExternal
    @Environment(\.codableErrorResponder) private var errorResponder
    
    internal func body(content: Content) -> some View {
        content
            .onChange(of: self.nav) {
                self.state.canShowErrors = $0.errorQueue.isEmpty == false
                self.state.selectedTags = $0.sidebar.selectedTag.map { Set([$0]) } ?? []
                self.state.selectedWebsites = $0.detail.selectedWebsites
            }
            .onChange(of: self.state.push_websiteAdd) { newValue in
                guard newValue else { return }
                defer { self.state.push_websiteAdd = false }
                switch self.controller.createWebsite() {
                case .success(let identifier):
                    self.nav.sidebar.isWebsiteAdd.editing = [identifier]
                case .failure(let error):
                    NSLog(String(describing: error))
                    self.errorResponder(.init(error as NSError))
                }
            }
            .onChange(of: self.state.push_tagAdd) { newValue in
                guard newValue else { return }
                defer { self.state.push_tagAdd = false }
                switch self.controller.createTag() {
                case .success(let identifier):
                    self.nav.sidebar.isTagsEdit.editing = [identifier]
                case .failure(let error):
                    NSLog(String(describing: error))
                    self.errorResponder(.init(error as NSError))
                }
            }
            .onChange(of: self.state.push_openInApp) { newValue in
                guard let newValue else { return }
                defer { self.state.push_openInApp = nil }
                self.nav.detail.isBrowse = newValue.single
            }
            .onChange(of: self.state.push_openExternal) { newValue in
                guard let newValue else { return }
                defer { self.state.push_openExternal = nil }
                newValue.single.map { self.openExternal($0) }
            }
            .onChange(of: self.state.push_share) { selection in
                guard selection.isEmpty == false else { return }
                defer { self.state.push_share = [] }
                // TODO: Share
            }
            .onChange(of: self.state.push_archiveYes) { selection in
                guard selection.isEmpty == false else { return }
                defer {
                    self.state.push_archiveYes = []
                    self.nav.detail.selectedWebsites = []
                }
                guard let error = ToolbarQuery.setArchive(true, selection, self.controller).error else { return }
                self.errorResponder(.init(error as NSError))
            }
            .onChange(of: self.state.push_archiveNo) { selection in
                guard selection.isEmpty == false else { return }
                defer {
                    self.state.push_archiveNo = []
                    self.nav.detail.selectedWebsites = []
                }
                guard let error = ToolbarQuery.setArchive(false, selection, self.controller).error else { return }
                self.errorResponder(.init(error as NSError))
            }
            .onChange(of: self.state.push_tagApply) { selection in
                guard selection.isEmpty == false else { return }
                defer {
                    self.state.push_tagApply = []
                    self.nav.detail.selectedWebsites = []
                }
                self.nav.detail.isTagApply = selection
            }
            .onChange(of: self.state.push_websiteEdit) { selection in
                guard selection.isEmpty == false else { return }
                defer {
                    self.state.push_websiteEdit = []
                    self.nav.detail.selectedWebsites = []
                }
                self.nav.detail.isWebsitesEdit.editing = selection
            }
            .onChange(of: self.state.push_tagsEdit) { selection in
                guard selection.isEmpty == false else { return }
                defer { self.state.push_tagsEdit = [] }
                self.nav.sidebar.isTagsEdit.editing = selection
            }
            .onChange(of: self.state.push_websiteDelete) { error in
                guard let error else { return }
                defer {
                    self.state.push_websiteDelete = nil
                    self.nav.detail.selectedWebsites = []
                }
                self.errorResponder(error)
            }
            .onChange(of: self.state.push_tagDelete) { error in
                guard let error else { return }
                defer {
                    self.state.push_tagDelete = nil
                    self.nav.sidebar.selectedTag = nil
                }
                self.errorResponder(error)
            }
            .onChange(of: self.state.push_showErrors) { newValue in
                guard newValue else { return }
                defer { self.state.push_showErrors = false }
                self.nav.detail.isErrorList.isPresented = true
            }
    }
}
