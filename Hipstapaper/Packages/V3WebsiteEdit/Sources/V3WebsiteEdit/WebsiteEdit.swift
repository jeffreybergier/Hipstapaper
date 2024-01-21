//
//  Created by Jeffrey Bergier on 2022/07/03.
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
import V3Model
import V3Store
import V3Errors
import V3Style
import V3Localize

public struct WebsiteEdit: View {
    
    public enum Screen {
        case website
        case tag
        case QRCode
    }

    @State private var screen: Screen
    @StateObject private var nav = Navigation.newEnvironment()
    @V3Style.WebsiteEdit private var style
    @HACK_macOS_Style private var hack_style
    
    private let selection: Website.Selection
    
    public init(selection: Website.Selection, start screen: Screen) {
        self.selection = selection
        _screen = .init(initialValue: screen)
    }
    
    public var body: some View {
        _WebsiteEdit(selection: self.selection, screen: self.$screen)
            .lift { self.size($0) }
            .modifier(self.hack_style.websiteEditPopoverSize)
            .environmentObject(self.nav)
    }
    
    @ViewBuilder private func size<V: View>(_ input: V) -> some View {
        switch self.screen {
        case .website:
            input.modifier(self.style.websiteSize)
        case .tag:
            input.modifier(self.style.tagSize)
        case .QRCode:
            input.modifier(self.style.websiteSize)
        }
    }
}

internal struct _WebsiteEdit: View {
    
    @Navigation             private var nav
    @V3Style.WebsiteEdit    private var style
    @V3Localize.WebsiteEdit private var text
    @HACK_macOS_Style       private var hack_style
    
    @Dismiss private var dismiss
    @Controller private var controller
    @ErrorStorage private var errors
    
    @Binding private var screen: WebsiteEdit.Screen
    private let selection: Website.Selection
    
    @Environment(\.sceneContext) private var HACK_sceneContext
    private var HACK_usesAbnormalToolbar: Bool {
        self.HACK_sceneContext != .normal
    }
    
    internal init(selection: Website.Selection, screen: Binding<WebsiteEdit.Screen>) {
        self.selection = selection
        _screen = screen
    }
    
    internal var body: some View {
        NavigationStack {
            TabView(selection: self.$screen) {
                FormParent(self.selection)
                    .tag(WebsiteEdit.Screen.website)
                    .tabItem {
                        self.style.tab
                            .action(text: self.text.tabWebsite)
                            .label
                    }
                Tag(self.selection)
                    .tag(WebsiteEdit.Screen.tag)
                    .tabItem {
                        self.style.tab
                            .action(text: self.text.tabTag)
                            .label
                    }
                QRCode(self.selection)
                    .tag(WebsiteEdit.Screen.QRCode)
                    .tabItem {
                        self.style.tab
                            .action(text: self.text.tabQRCode)
                            .label
                    }
            }
            .HACK_scrollDismissesKeyboardImmediately
            .modifier(self.hack_style.tabParentPadding)
            .lift { self.HACK_tabViewTopPadding($0) }
            .modifier(self.hack_style.formTextFieldStyle)
            .modifier(
                JSBToolbar(
                    title: self.title,
                    done: self.text.done,
                    delete: self.text.delete,
                    doneAction: self.dismiss,
                    deleteAction: self.delete,
                    macOSLegacyBehavior: self.HACK_usesAbnormalToolbar
                )
            )
        }
        .modifier(
            ErrorStorage.Presenter(
                isAlreadyPresenting: self.nav.isPresenting,
                toPresent: self.$nav.isError,
                router: errorRouter(_:)
            )
        )
    }
    
    private var title: String {
        switch self.screen {
        case .website:
            return self.text.titleWebsite
        case .tag:
            return self.text.titleTag
        case .QRCode:
            return self.text.titleQRCode
        }
    }
    
    private func delete() {
        let error = DeleteWebsiteConfirmationError(self.selection)
        { selection in
            switch self.controller.delete(selection) {
            case .success:
                self.dismiss()
            case .failure(let error):
                self.errors.append(error)
            }
        }
        self.errors.append(error)
    }
    
    @ViewBuilder private func HACK_tabViewTopPadding<V: View>(_ input: V) -> some View {
        #if os(macOS)
        if self.HACK_usesAbnormalToolbar {
            input
        } else {
            input.padding(.top, nil)
        }
        #else
        input
        #endif
    }
}

extension String {
    fileprivate static let toolbarName         = "Toolbar-Base"
    fileprivate static let toolbarButtonDone   = "Toolbar-Button-Done"
    fileprivate static let toolbarButtonDelete = "Toolbar-Button-Delete"
}

extension View {
    fileprivate var HACK_scrollDismissesKeyboardImmediately: some View {
        #if os(visionOS)
        return self
        #else
        return self.scrollDismissesKeyboard(.immediately)
        #endif
    }
}
