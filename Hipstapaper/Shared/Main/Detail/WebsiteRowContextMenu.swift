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
    @ObservedObject var controller: WebsiteController
    
    @State private var isDeleteConfirmPresented = false
    
    @StateObject private var modalPresentation = ModalPresentation.Wrap()
    @EnvironmentObject private var windowPresentation: WindowPresentation
    @Environment(\.openURL) private var externalPresentation
    
    func body(content: Content) -> some View {
        content
            .modifier(SharePresentable(selectedWebsites: self.controller.selectedWebsites))
            .modifier(TagApplyPresentable(controller: self.controller.controller,
                                          selectedWebsites: self.controller.selectedWebsites))
            .alert(isPresented: self.$isDeleteConfirmPresented) {
                Alert(
                    // TODO: Localized and fix this
                    title: STZ.VIEW.TXT("Delete"),
                    message: STZ.VIEW.TXT("Are you sure you want to delete 1 item? This action cannot be undone."),
                    primaryButton: .destructive(STZ.VIEW.TXT("Delete"), action: self.controller.delete),
                    secondaryButton: .cancel()
                )
            }
            .contextMenu {
                Group {
                    STZ.TB.OpenInApp.context(isEnabled: self.controller.canOpen(in: self.windowPresentation),
                                             action: { self.modalPresentation.value = .browser(nil) })
                    STZ.TB.OpenInBrowser.context(isEnabled: self.controller.canOpen(in: self.windowPresentation),
                                                 action: { self.controller.open(in: self.externalPresentation) })
                }
                Group {
                    STZ.TB.Archive.context(isEnabled: self.controller.canArchive(),
                                           action: self.controller.archive)
                    STZ.TB.Unarchive.context(isEnabled: self.controller.canUnarchive(),
                                             action: self.controller.unarchive)
                }
                Group {
                    STZ.TB.Share.context(isEnabled: self.controller.canShare(),
                                         action: { self.modalPresentation.value = .share })
                    STZ.TB.TagApply.context(action: { self.modalPresentation.value = .tagApply })
                }
                Group {
                    STZ.TB.DeleteWebsite.context(isEnabled: self.controller.canDelete(),
                                                 action: { self.isDeleteConfirmPresented = true })
                }
            }
            .environmentObject(self.modalPresentation)

    }
    
}
