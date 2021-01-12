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

extension STZ {
    public enum MDL {
        public struct Done: ViewModifier {
            let kind: Presentable.Type
            let doneAction: Action
            public init(kind: Presentable.Type, done: @escaping Action) {
                self.kind = kind
                self.doneAction = done
            }
            #if os(macOS)
            // TODO: Remove this once its not broken on the mac
            public func body(content: Content) -> some View {
                return VStack(spacing: 0) {
                    Toolbar {
                        HStack {
                            Spacer()
                            Text.ModalTitle(self.kind.noun)
                            Spacer()
                            STZ.BTN.Done.button(doneStyle: true, action: self.doneAction)
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
                        .navigationBarTitle(self.kind.noun, displayMode: .inline)
                        .toolbar(id: "Modal.Done") {
                            ToolbarItem(id: "Modal.Done.0", placement: .confirmationAction) {
                                STZ.BTN.Done.button(doneStyle: true, action: self.doneAction)
                            }
                        }
                }.navigationViewStyle(StackNavigationViewStyle())
            }
            #endif
        }
        
        public struct Save: ViewModifier {
            
            public typealias CanSave = () -> Bool
            
            let kind: Presentable.Type
            let saveAction: Action
            let cancelAction: Action
            let canSave: CanSave
            
            public init(kind: Presentable.Type,
                        cancel: @escaping Action,
                        save: @escaping Action,
                        canSave: CanSave?)
            {
                self.kind = kind
                self.cancelAction = cancel
                self.saveAction = save
                self.canSave = canSave ?? { true }
            }
            
            #if os(macOS)
            // TODO: Remove this once its not broken on the mac
            public func body(content: Content) -> some View {
                return VStack(spacing: 0) {
                    Toolbar {
                        HStack {
                            STZ.BTN.Cancel.button(action: self.cancelAction)
                            Spacer()
                            Text.ModalTitle(self.kind.noun)
                            Spacer()
                            STZ.BTN.Save.button(doneStyle: true,
                                                isDisabled: !self.canSave(),
                                                action: self.saveAction)
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
                        .navigationBarTitle(self.kind.noun, displayMode: .inline)
                        .toolbar(id: "Modal.Save") {
                            ToolbarItem(id: "Modal.Save.0", placement: .cancellationAction) {
                                STZ.BTN.Cancel.button(action: self.cancelAction)
                            }
                            ToolbarItem(id: "Modal.Save.1", placement: .confirmationAction) {
                                STZ.BTN.Save.button(doneStyle: true,
                                                    isDisabled: !self.canSave(),
                                                    action: self.saveAction)
                            }
                        }
                }.navigationViewStyle(StackNavigationViewStyle())
            }
            #endif
        }
    }
}

public struct ModalSelectionStyle: ViewModifier {
    public init() {}
    public func body(content: Content) -> some View {
        #if os(macOS)
        return content
        #else
        return content
            .listStyle(PlainListStyle())
            .modifier(ListEditMode())
        #endif
    }
}
