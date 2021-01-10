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
import Localize
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
                Share(items: [self.item.value.preferredURL!],
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
                    Button(action: { self.presentation.item = self.item },
                           label: { Label(Verb.Open, systemImage: "safari") })
                        .disabled(self.item.value.preferredURL == nil)
                    Button(action: { self.openURL(self.item.value.preferredURL!) },
                           label: { Label(Verb.Safari, systemImage: "safari.fill") })
                        .disabled(self.item.value.preferredURL == nil)
                }
                Group {
                    Button(action: self.archive,
                           label: { Label(Verb.Archive, systemImage: "tray.and.arrow.down") })
                        .disabled(self.item.value.isArchived)
                    Button(action: self.unarchive,
                           label: { Label(Verb.Unarchive, systemImage: "tray.and.arrow.up") })
                        .disabled(!self.item.value.isArchived)
                }
                Group {
                    Button(action: { self.isSharePresented = true },
                           label: { Label(Verb.Share, systemImage: "square.and.arrow.up") })
                        .disabled(self.item.value.preferredURL == nil)
                    Button(action: { self.isTagApplyPresented = true },
                           label: { Label(Verb.AddAndRemoveTags, systemImage: "tag") })
                        .disabled(self.item.value.preferredURL == nil)
                }
                Group {
                    Button(action: { self.isDeleteConfirmPresented = true },
                           label: { Label("Delete", systemImage: "trash") })
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
