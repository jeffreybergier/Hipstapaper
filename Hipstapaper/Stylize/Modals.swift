//
//  Created by Jeffrey Bergier on 2020/12/27.
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
import Localize

public enum Modal { }

extension Modal {
    
    public typealias Action = () -> Void
    
    public struct Done: ViewModifier {
        
        let title: LocalizedStringKey
        let done: Action
        
        public init(title: LocalizedStringKey, done: @escaping Action) {
            self.title = title
            self.done = done
        }
        
        #if os(macOS)
        // TODO: Remove this once its not broken on the mac
        public func body(content: Content) -> some View {
            return VStack(spacing: 0) {
                Toolbar {
                    HStack {
                        Spacer()
                        Text.ModalTitle(self.title)
                        Spacer()
                        ButtonDone(Verb.Done, action: self.done)
                            .keyboardShortcut(.defaultAction)
                    }
                }
                content
                Spacer(minLength: 0)
            }
        }
        #else
        public func body(content: Content) -> some View {
            return NavigationView {
                content
                    .navigationBarTitle(self.title, displayMode: .inline)
                    .toolbar(id: "Modal.Done") {
                        ToolbarItem(id: "0", placement: ToolbarItemPlacement.primaryAction,
                                    content: { ButtonDone(Verb.Done, action: self.done) })
                    }
            }
        }
        #endif
        
    }
}


