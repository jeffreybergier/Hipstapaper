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
    
    @ObservedObject var dataSource: WebsiteDataSource
    
    @EnvironmentObject private var modalPresentation: ModalPresentation.Wrap
    @EnvironmentObject private var windowPresentation: WindowPresentation
    @EnvironmentObject private var errorQ: STZ.ERR.ViewModel
    @Environment(\.openURL) private var externalPresentation
    
    var body: some View {
        XPL.List(data: self.dataSource.data,
                 selection: self.$dataSource.selection,
                 open: self.open,
                 menu: self.contextMenu)
        { item in
            WebsiteRow(item: item)
        }
        .alert(isPresented: self.$modalPresentation.isDelete) {
            Alert(
                // TODO: Localized and fix this
                title: STZ.VIEW.TXT("Delete"),
                message: STZ.VIEW.TXT("This action cannot be undone."),
                primaryButton: .destructive(STZ.VIEW.TXT("Delete"),
                                            action: { self.dataSource.delete(self.errorQ) }),
                secondaryButton: .cancel()
            )
        }
        .animation(.default)
        .onAppear() { self.dataSource.activate() }
        .onDisappear() { self.dataSource.deactivate() }
        .modifier(WebsiteListTitle(query: self.dataSource.query))
        .modifier(DetailToolbar.Shared(controller: self.dataSource.controller,
                                       selection: self.$dataSource.selection,
                                       query: self.$dataSource.query,
                                       dataSource: self.dataSource))
    }
}

extension WebsiteList {
    private func open(_ items: Set<AnyElementObserver<AnyWebsite>>) {
        if self.windowPresentation.features.contains([.bulkActivation, .multipleWindows]) {
            let validURLs = Set(items.compactMap({ $0.value.preferredURL }))
            self.windowPresentation.show(validURLs, error: { _ in })
        } else {
            guard let validItem = items.first(where: { $0.value.preferredURL != nil }) else { return }
            self.modalPresentation.value = .browser(validItem)
        }
    }
    
    @ViewBuilder private func contextMenu(_ selection: Set<AnyElementObserver<AnyWebsite>>) -> some View {
        STZ.VIEW.TXT("\(selection.count) selected")
        Group {
            STZ.TB.OpenInApp.context(isEnabled: WH.canOpen(selection, in: self.windowPresentation)) {
                guard let fail = WH.open(selection, in: self.windowPresentation, self.errorQ) else { return }
                self.modalPresentation.value = .browser(fail)
            }
            STZ.TB.OpenInBrowser.context(isEnabled: WH.canOpen(selection, in: self.windowPresentation),
                                         action: { WH.open(selection, in: self.externalPresentation) })
        }
        Group {
            STZ.TB.Archive.context(isEnabled: WH.canArchive(selection),
                                   action: { WH.archive(selection, self.dataSource.controller, self.errorQ) })
            STZ.TB.Unarchive.context(isEnabled: WH.canUnarchive(selection),
                                     action: { WH.unarchive(selection, self.dataSource.controller, self.errorQ) })
        }
        Group {
            STZ.TB.Share.context(isEnabled: WH.canShare(selection)) {
                self.modalPresentation.value = .share(selection)
            }
            STZ.TB.TagApply.context(isEnabled: WH.canTag(selection)) {
                self.dataSource.selection = selection
                self.modalPresentation.value = .tagApply(selection)
            }
        }
        Group {
            STZ.TB.DeleteWebsite.context(isEnabled: WH.canDelete(selection)) {
                // TODO: Find a way to not forcefully change the selection
                self.dataSource.selection = selection
                self.modalPresentation.value = .delete
            }
        }
    }
}

#if DEBUG
struct WebsiteList_Preview: PreviewProvider {
    static var previews: some View {
        WebsiteList(dataSource: WebsiteDataSource(controller: P_Controller()))
    }
}
#endif
