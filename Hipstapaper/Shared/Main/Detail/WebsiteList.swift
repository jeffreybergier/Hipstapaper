//
//  Created by Jeffrey Bergier on 2020/11/30.
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
import XPList

struct WebsiteList: View {
    
    @ObservedObject private var controller: WebsiteController
    @EnvironmentObject private var modalPresentation: ModalPresentation.Wrap
    @EnvironmentObject private var windowPresentation: WindowPresentation
    @EnvironmentObject private var errorQ: STZ.ERR.ViewModel
    @Environment(\.openURL) private var externalPresentation
    
    init(controller: Controller, selectedTag: AnyElement<AnyTag>) {
        let websiteController = WebsiteController(controller: controller, selectedTag: selectedTag)
        _controller = ObservedObject(initialValue: websiteController)
    }
    
    init(controller: WebsiteController) {
        _controller = ObservedObject(initialValue: controller)
    }
    
    var body: some View {
        XPL.List(data: self.controller.all,
                 selection: self.$controller.selectedWebsites,
                 open: self.open,
                 menu: self.contextMenu)
        { item in
            WebsiteRow(item.value)
        }
        .alert(isPresented: self.$modalPresentation.isDelete) {
            Alert(
                // TODO: Localized and fix this
                title: STZ.VIEW.TXT("Delete"),
                message: STZ.VIEW.TXT("This action cannot be undone."),
                primaryButton: .destructive(STZ.VIEW.TXT("Delete"),
                                            action: { self.controller.delete(self.errorQ) }),
                secondaryButton: .cancel()
            )
        }
        .animation(.default)
        .modifier(WebsiteListTitle(query: self.controller.query))
        .onAppear() { self.controller.activate() }
        .onDisappear() { self.controller.deactivate() }
    }
}

extension WebsiteList {
    private func open(_ items: Set<AnyElement<AnyWebsite>>) {
        if self.windowPresentation.features.contains([.bulkActivation, .multipleWindows]) {
            let validURLs = Set(items.compactMap({ $0.value.preferredURL }))
            self.windowPresentation.show(validURLs, error: { _ in })
        } else {
            guard let validItem = items.first(where: { $0.value.preferredURL != nil }) else { return }
            self.modalPresentation.value = .browser(validItem)
        }
    }
    
    private func contextMenu(_ items: Set<AnyElement<AnyWebsite>>) -> some View {
        // TODO: Remove this temp controller nonesense
        let controller = WebsiteController(controller: self.controller.controller)
        controller.selectedWebsites = items
        return _contextMenu(controller)
    }
    
    @ViewBuilder private func _contextMenu(_ tmpCtrlr: WebsiteController) -> some View {
        STZ.VIEW.TXT("\(tmpCtrlr.selectedWebsites.count) selected")
        Group {
            STZ.TB.OpenInApp.context(isEnabled: tmpCtrlr.canOpen(in: self.windowPresentation)) {
                guard let fail = tmpCtrlr.open(in: self.windowPresentation) else { return }
                self.modalPresentation.value = .browser(fail)
            }
            STZ.TB.OpenInBrowser.context(isEnabled: tmpCtrlr.canOpen(in: self.windowPresentation),
                                         action: { tmpCtrlr.open(in: self.externalPresentation) })
        }
        Group {
            STZ.TB.Archive.context(isEnabled: tmpCtrlr.canArchive(),
                                   action: { tmpCtrlr.archive(self.errorQ) })
            STZ.TB.Unarchive.context(isEnabled: tmpCtrlr.canUnarchive(),
                                     action: { tmpCtrlr.unarchive(self.errorQ) })
        }
        Group {
            STZ.TB.Share.context(isEnabled: tmpCtrlr.canShare()) {
                self.controller.selectedWebsites = tmpCtrlr.selectedWebsites
                self.modalPresentation.value = .share
            }
            STZ.TB.TagApply.context(isEnabled: tmpCtrlr.canTag()) {
                self.controller.selectedWebsites = tmpCtrlr.selectedWebsites
                self.modalPresentation.value = .tagApply
            }
        }
        Group {
            STZ.TB.DeleteWebsite.context(isEnabled: tmpCtrlr.canDelete()) {
                // TODO: Find a way to not forcefully change the selection
                self.controller.selectedWebsites = tmpCtrlr.selectedWebsites
                self.modalPresentation.value = .delete
            }
        }
    }
}

#if DEBUG
struct WebsiteList_Preview: PreviewProvider {
    static var previews: some View {
        WebsiteList(controller: WebsiteController(controller: P_Controller()))
    }
}
#endif
