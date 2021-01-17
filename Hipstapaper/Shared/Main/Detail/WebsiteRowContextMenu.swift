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

enum Menu {
    struct Website: ViewModifier {
        
        let item: AnyElement<AnyWebsite>
        @ObservedObject var controller: WebsiteController
        
        @StateObject private var modalPresentation = ModalPresentation.Wrap()
        
        // TODO: Combine these two context menus
        func body(content: Content) -> some View {
            if self.controller.selectedWebsites.isEmpty {
                return AnyView(
                    content
                        .modifier(Single(item: self.item, controller: self.controller.controller))
                        .environmentObject(self.modalPresentation)
                )
            } else {
                return AnyView(
                    content
                        .modifier(Multi(controller: self.controller))
                        .environmentObject(self.modalPresentation)
                )
            }
        }
    }
}

extension Menu.Website {
    struct Multi: ViewModifier {
        @ObservedObject var controller: WebsiteController
        @EnvironmentObject private var modalPresentation: ModalPresentation.Wrap
        @EnvironmentObject private var windowPresentation: WindowPresentation
        @Environment(\.openURL) private var externalPresentation
        func body(content: Content) -> some View {
            ZStack {
                Color.clear.frame(width: 1, height: 1).modifier(
                    TagApplyPresentable(controller: self.controller.controller,
                                        selectedWebsites: self.controller.selectedWebsites)
                )
                Color.clear.frame(width: 1, height: 1).modifier(
                    SharePresentable(selectedWebsites: self.controller.selectedWebsites)
                )
                Color.clear.frame(width: 1, height: 1)
                    .modifier(BrowserPresentable())
                Color.clear.frame(width: 1, height: 1)
                    .alert(isPresented: self.$modalPresentation.isDelete) {
                        Alert(
                            // TODO: Localized and fix this
                            title: STZ.VIEW.TXT("Delete"),
                            message: STZ.VIEW.TXT("This action cannot be undone."),
                            primaryButton: .destructive(STZ.VIEW.TXT("Delete"), action: self.controller.delete),
                            secondaryButton: .cancel()
                        )
                    }
                content
            }
            .contextMenu {
                STZ.VIEW.TXT("Multi: \(self.controller.selectedWebsites.count) selected")
                Group {
                    STZ.TB.OpenInApp.context(isEnabled: self.controller.canOpen(in: self.windowPresentation)) {
                        guard let fail = self.controller.open(in: self.windowPresentation) else { return }
                        self.modalPresentation.value = .browser(fail)
                    }
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
                    STZ.TB.TagApply.context(isEnabled: self.controller.canTag(),
                                            action: { self.modalPresentation.value = .tagApply })
                }
                Group {
                    STZ.TB.DeleteWebsite.context(isEnabled: self.controller.canDelete(),
                                                 action: { self.modalPresentation.value = .delete })
                }
            }
        }
    }
    
    struct Single: ViewModifier {
        let item: AnyElement<AnyWebsite>
        let controller: Controller
        @EnvironmentObject private var modalPresentation: ModalPresentation.Wrap
        @EnvironmentObject private var windowPresentation: WindowPresentation
        @Environment(\.openURL) private var externalPresentation
        func body(content: Content) -> some View {
            ZStack {
                Color.clear.frame(width: 1, height: 1).modifier(
                    TagApplyPresentable(controller: self.controller,
                                        selectedWebsites: [self.item])
                )
                Color.clear.frame(width: 1, height: 1).modifier(
                    SharePresentable(selectedWebsites: [self.item])
                )
                Color.clear.frame(width: 1, height: 1)
                    .modifier(BrowserPresentable())
                Color.clear.frame(width: 1, height: 1)
                    .alert(isPresented: self.$modalPresentation.isDelete) {
                        Alert(
                            // TODO: Localized and fix this
                            title: STZ.VIEW.TXT("Delete"),
                            message: STZ.VIEW.TXT("This action cannot be undone."),
                            primaryButton: .destructive(STZ.VIEW.TXT("Delete"), action: self.delete),
                            secondaryButton: .cancel()
                        )
                    }
                content
            }
            .contextMenu {
                STZ.VIEW.TXT("Single: 1 selected")
                Group {
                    STZ.TB.OpenInApp.context(isEnabled: self.canOpen(),
                                             action: self.openInApp)
                    STZ.TB.OpenInBrowser.context(isEnabled: self.canOpen(),
                                                 action: self.openExternal)
                }
                Group {
                    STZ.TB.Archive.context(isEnabled: self.canArchive(),
                                           action: self.archive)
                    STZ.TB.Unarchive.context(isEnabled: self.canUnarchive(),
                                             action: self.unarchive)
                }
                Group {
                    STZ.TB.Share.context(action: { self.modalPresentation.value = .share })
                    STZ.TB.TagApply.context(action: { self.modalPresentation.value = .tagApply })
                }
                Group {
                    STZ.TB.DeleteWebsite.context(action: { self.modalPresentation.value = .delete })
                }
            }
        }
        
        private func canOpen() -> Bool {
            return self.item.value.preferredURL != nil
        }
        private func canArchive() -> Bool {
            return !self.item.value.isArchived
        }
        private func canUnarchive() -> Bool {
            return self.item.value.isArchived
        }
        private func openInApp() {
            let wm = self.windowPresentation
            if wm.features.contains([.multipleWindows]) {
                wm.show([self.item.value.preferredURL!]) {
                    // TODO: Do something with this error
                    print($0)
                }
            } else {
                self.modalPresentation.value = .browser(self.item)
            }
        }
        private func openExternal() {
            self.externalPresentation(self.item.value.preferredURL!)
        }
        private func archive() {
            // TODO: Remove this try
            try! self.controller.update([self.item], .init(isArchived: true)).get()
        }
        private func unarchive() {
            // TODO: Remove this try
            try! self.controller.update([self.item], .init(isArchived: false)).get()
        }
        private func delete() {
            // TODO: Remove this try
            try! self.controller.delete([self.item]).get()
        }
    }
}

