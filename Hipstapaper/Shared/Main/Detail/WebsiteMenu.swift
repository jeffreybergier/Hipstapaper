//
//  Created by Jeffrey Bergier on 2021/02/09.
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
import XPList
import Datum
import Stylize

struct WebsiteMenu: ViewModifier {
    
    @EnvironmentObject private var modalPresentation: ModalPresentation.Wrap
    @EnvironmentObject private var windowPresentation: WindowPresentation
    @EnvironmentObject private var errorQ: STZ.ERR.ViewModel
    @Environment(\.openURL) private var externalPresentation
    
    private let selection: WH.Selection
    private let controller: Controller
    
    init(_ selection: WH.Selection, _ controller: Controller) {
        self.selection = selection
        self.controller = controller
    }
    
    func body(content: Content) -> some View {
        content.contextMenu() {
            self.contextMenu()
        }
    }
    
    @ViewBuilder private func contextMenu() -> some View {
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
                                   action: { WH.archive(selection, self.controller, self.errorQ) })
            STZ.TB.Unarchive.context(isEnabled: WH.canUnarchive(selection),
                                     action: { WH.unarchive(selection, self.controller, self.errorQ) })
        }
        Group {
            STZ.TB.Share.context(isEnabled: WH.canShare(selection)) {
                self.modalPresentation.value = .share(selection)
            }
            STZ.TB.TagApply.context(isEnabled: WH.canTag(selection)) {
                self.modalPresentation.value = .tagApply(selection)
            }
        }
        Group {
            STZ.TB.DeleteWebsite.context(isEnabled: WH.canDelete(selection)) {
                self.modalPresentation.value = .deleteWebsite(selection)
            }
        }
    }
}
