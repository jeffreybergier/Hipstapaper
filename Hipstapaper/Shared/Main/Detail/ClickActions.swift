//
//  Created by Jeffrey Bergier on 2021/01/03.
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
import Browse

enum ClickActions {
    class Controller: ObservableObject {
        @Published fileprivate var item: AnyElement<AnyWebsite>!
        @Published fileprivate var isPresented: Bool = false
    }
    
    struct Modifier: ViewModifier {
        
        @ObservedObject var controller: Controller
        @EnvironmentObject private var windowManager: WindowManager
        // TODO: remove !
        private var item: AnyWebsite { self.controller.item.value }
        func body(content: Content) -> some View {
            content.sheet(isPresented: self.$controller.isPresented) { () -> Browser in
                let vm = Browse.ViewModel(url: self.item.preferredURL!) {
                    self.controller.isPresented = false
                }
                return Browser(vm)
                // TODO: Add this back
//                    .onDisappear { self.controller.item = nil }
            }
        }
    }
    
    struct SingleClick: ViewModifier {
        
        let item: AnyElement<AnyWebsite>
        @ObservedObject var controller: Controller

        func body(content: Content) -> some View {
            #if os(macOS)
            return content
            #else
            return Button(action: {
                self.controller.item = self.item
                self.controller.isPresented = true
            },label: { content })
            #endif
        }
    }
}
