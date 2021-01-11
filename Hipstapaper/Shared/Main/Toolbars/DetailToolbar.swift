//
//  Created by Jeffrey Bergier on 2020/12/03.
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
import Browse

struct DetailToolbar: ViewModifier {
    
    @ObservedObject var controller: WebsiteController
    @EnvironmentObject var windowManager: WindowManager
    @State var presentation = DetailToolbarPresentation.Wrap()
    @State var popoverAlignment: Alignment = .topTrailing
    
    func body(content: Content) -> some View {
        return ZStack(alignment: self.popoverAlignment) {
            // TODO: Hack when toolbars work properly with popovers
            Color.clear.frame(width: 1, height: 1)
                .popover(isPresented: self.$presentation.isTagApply) { () -> TagApply in
                    TagApply(selectedWebsites: self.controller.selectedWebsites,
                             controller: self.controller.controller,
                             done: { self.presentation.value = .none })
                }
            
            Color.clear.frame(width: 1, height: 1)
                .popover(isPresented: self.$presentation.isShare) {
                    Share(items: self.controller.selectedWebsites.compactMap { $0.value.preferredURL },
                          completion:  { self.presentation.value = .none })
                }
            
            Color.clear.frame(width: 1, height: 1)
                .popover(isPresented: self.$presentation.isSearch) {
                    Search(searchString: self.$controller.query.search,
                           doneAction: { self.presentation.value = .none })
                }
            
            Color.clear.frame(width: 1, height: 1)
                .popover(isPresented: self.$presentation.isSort) {
                    Sort(selection: self.$controller.query.sort, doneAction: { self.presentation.value = .none })
                }
            #if os(macOS)
            content.modifier(DetailToolbar_macOS(controller: self.controller,
                                                 presentation: self.$presentation))
            #else
            content.modifier(DetailToolbar_iOS(controller: self.controller,
                                               presentation: self.$presentation,
                                               popoverAlignment: self.$popoverAlignment))
            #endif
        }
    }
}

struct OpenWebsiteDisabler: ViewModifier {
    
    let selectionCount: Int
    @EnvironmentObject var windowManager: WindowManager
    
    init(_ selectionCount: Int) {
        self.selectionCount = selectionCount
    }
    
    func body(content: Content) -> some View {
        if self.windowManager.features.contains(.bulkActivation) {
            return content.disabled(self.selectionCount < 1)
        } else {
            return content.disabled(self.selectionCount != 1)
        }
    }
}
