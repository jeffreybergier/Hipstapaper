//
//  Created by Jeffrey Bergier on 2021/02/09.
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
import XPList
import Datum
import Stylize

struct WebsiteMenu: ViewModifier {
    
    @EnvironmentObject private var modalPresentation: ModalPresentation.Wrap
    @EnvironmentObject private var windowPresentation: WindowPresentation
    @EnvironmentObject private var errorQ: ErrorQueue
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
                let error = DeleteError.website {
                    WH.delete(self.selection, self.controller, self.errorQ)
                }
                self.errorQ.queue.append(error)
            }
        }
    }
}
