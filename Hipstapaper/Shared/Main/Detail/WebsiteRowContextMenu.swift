//
//  Created by Jeffrey Bergier on 2021/01/10.
//
//  Copyright © 2020 Saturday Apps.
//
//  This file is part of Hipstapaper.
//
//  Hipstapaper is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Hipstapaper is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Hipstapaper.  If not, see <http://www.gnu.org/licenses/>.
//

import SwiftUI
import Datum
import Stylize

struct WebsiteRowContextMenu: ViewModifier {
    
    let item: AnyElement<AnyWebsite>
    let controller: Controller
    
    @State private var isSharePresented = false
    @State private var isTagApplyPresented = false
    @State private var isDeleteConfirmPresented = false
    
    @Environment(\.openURL) private var openURL
    @EnvironmentObject private var presentation: BrowserPresentation
    
    func body(content: Content) -> some View {
        content
            .popover(isPresented: self.$isSharePresented) {
                STZ.SHR(items: [self.item.value.preferredURL!],
                        completion: { self.isSharePresented = false })
            }
            .popover(isPresented: self.$isTagApplyPresented) {
                TagApply(selectedWebsites: [self.item],
                         controller: self.controller,
                         done: { self.isTagApplyPresented = false })
            }
            .alert(isPresented: self.$isDeleteConfirmPresented) {
                Alert(
                    title: Text("Delete"),
                    message: Text("Are you sure you want to delete 1 item? This action cannot be undone."),
                    primaryButton: .destructive(Text("Delete"), action: self.delete),
                    secondaryButton: .cancel()
                )
            }
            .contextMenu {
                Group {
                    STZ.TB.OpenInApp.button(isDisabled: self.item.value.preferredURL == nil,
                                                   action: { self.presentation.item = self.item })
                    STZ.TB.OpenInBrowser.button(isDisabled: self.item.value.preferredURL == nil,
                                                       action: { self.openURL(self.item.value.preferredURL!) })
                }
                Group {
                    STZ.TB.Archive.button(isDisabled: self.item.value.isArchived,
                                                 action: self.archive)
                    STZ.TB.Unarchive.button(isDisabled: !self.item.value.isArchived,
                                                   action: self.unarchive)
                }
                Group {
                    STZ.TB.Share.button(isDisabled: self.item.value.preferredURL == nil,
                                               action: { self.isSharePresented = true })
                    STZ.TB.TagApply.button(action: { self.isTagApplyPresented = true })
                }
                Group {
                    STZ.TB.DeleteWebsite.button(action: { self.isDeleteConfirmPresented = true })
                }
            }
    }
    
    private func archive() {
        let r = self.controller.update([item], .init(isArchived: true))
        guard case .failure(let error) = r else { return }
        print(error)
    }
    
    private func unarchive() {
        let r = self.controller.update([item], .init(isArchived: false))
        guard case .failure(let error) = r else { return }
        print(error)
    }
    
    private func delete() {
        let r = self.controller.delete(self.item)
        guard case .failure(let error) = r else { return }
        print(error)
    }
}
