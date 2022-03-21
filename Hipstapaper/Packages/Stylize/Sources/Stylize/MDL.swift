//
//  Created by Jeffrey Bergier on 2020/12/27.
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
import Localize

extension STZ {
    public enum MDL { }
}

extension STZ.MDL {
    public struct Done: ViewModifier {
        
        public let kind: Presentable.Type
        public let doneAction: Action
        
        @Localize private var text
        
        public init(kind: Presentable.Type, done: @escaping Action) {
            self.kind = kind
            self.doneAction = done
        }
        #if os(macOS)
        // TODO: Remove this once its not broken on the mac
        public func body(content: Content) -> some View {
            return VStack(spacing: 0) {
                HStack {
                    Spacer()
                    STZ.VIEW.TXT(self.kind.noun.loc(self.text))
                        .modifier(STZ.FNT.MDL.Title.apply())
                        .modifier(STZ.CLR.MDL.Title.foreground())
                    Spacer()
                    STZ.BTN.Done.button(doneStyle: true,
                                        bundle: self.text,
                                        action: self.doneAction)
                }
                .modifier(STZ.VIEW.TB_HACK())
                content
                Spacer(minLength: 0)
            }
        }
        #else
        public func body(content: Content) -> some View {
            return NavigationView {
                content
                    .navigationBarTitle(self.kind.verb.loc(self.text), displayMode: .inline)
                    .toolbar(id: "Modal.Done") {
                        ToolbarItem(id: "Modal.Done.0", placement: .confirmationAction) {
                            STZ.BTN.Done.button(doneStyle: true,
                                                bundle: self.text,
                                                action: self.doneAction)
                        }
                    }
            }.navigationViewStyle(StackNavigationViewStyle())
        }
        #endif
    }
}

extension STZ.MDL {
    public struct Save: ViewModifier {
        
        public typealias CanSave = () -> Bool
        public let kind: Presentable.Type
        public let saveAction: Action
        public let cancelAction: Action
        public let canSave: CanSave
        
        @Localize private var text
        
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
                HStack {
                    STZ.BTN.Cancel.button(bundle: self.text,
                                          action: self.cancelAction)
                    Spacer()
                    STZ.VIEW.TXT(self.kind.noun.loc(self.text))
                        .modifier(STZ.FNT.MDL.Title.apply())
                        .modifier(STZ.CLR.MDL.Title.foreground())
                    Spacer()
                    STZ.BTN.Save.button(doneStyle: true,
                                        isEnabled: self.canSave(),
                                        bundle: self.text,
                                        action: self.saveAction)
                }
                .modifier(STZ.VIEW.TB_HACK())
                content
                Spacer(minLength: 0)
            }
        }
        #else
        public func body(content: Content) -> some View {
            return NavigationView {
                content
                    .navigationBarTitle(self.kind.verb.loc(self.text), displayMode: .inline)
                    .toolbar(id: "Modal.Save") {
                        ToolbarItem(id: "Modal.Save.0", placement: .cancellationAction) {
                            STZ.BTN.Cancel.button(bundle: self.text, action: self.cancelAction)
                        }
                        ToolbarItem(id: "Modal.Save.1", placement: .confirmationAction) {
                            STZ.BTN.Save.button(doneStyle: true,
                                                isEnabled: self.canSave(),
                                                bundle: self.text,
                                                action: self.saveAction)
                        }
                    }
            }.navigationViewStyle(StackNavigationViewStyle())
        }
        #endif
    }
}
