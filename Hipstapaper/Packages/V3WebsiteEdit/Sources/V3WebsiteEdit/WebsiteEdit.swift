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
import V3Errors
import V3Style
import V3Localize

public struct WebsiteEdit: View {
    
    public enum Screen {
        case website
        case tag
    }

    @State private var screen: Screen
    @StateObject private var nav = Navigation.newEnvironment()
    @V3Style.WebsiteEdit private var style
    
    private let selection: Website.Selection
    
    public init(selection: Website.Selection, start screen: Screen) {
        self.selection = selection
        _screen = .init(initialValue: screen)
    }
    
    public var body: some View {
        _WebsiteEdit(selection: self.selection, screen: self.$screen)
            .lift { self.size($0) }
            .environmentObject(self.nav)
    }
    
    @ViewBuilder private func size<V: View>(_ input: V) -> some View {
        switch self.screen {
        case .website:
            input.modifier(self.style.websiteSize)
        case .tag:
            input.modifier(self.style.tagSize)
        }
    }
}

internal struct _WebsiteEdit: View {
    
    @Navigation private var nav
    @Errors private var errorQueue
    @Binding private var screen: WebsiteEdit.Screen
    
    @V3Style.WebsiteEdit private var style
    @V3Localize.WebsiteEdit private var text
    
    @Dismiss private var dismiss
    
    private let selection: Website.Selection
    
    internal init(selection: Website.Selection, screen: Binding<WebsiteEdit.Screen>) {
        self.selection = selection
        _screen = screen
    }
    
    internal var body: some View {
        ErrorResponder(toPresent: self.$nav.isError,
                       storeErrors: self.nav.isPresenting,
                       inStorage: self.$errorQueue)
        {
            TabView(selection: self.$screen) {
                FormParent(self.selection)
                    .tag(WebsiteEdit.Screen.website)
                    .tabItem {
                        self.style.tab.action(text: self.text.tabWebsite).label
                    }
                Tag(self.selection)
                    .tag(WebsiteEdit.Screen.tag)
                    .tabItem {
                        self.style.tab.action(text: self.text.tabTag).label
                    }
            }
        } onConfirmation: {
            switch $0 {
            case .deleteTags:
                NSLog("Probably unexpected: \($0)")
                break
            case .deleteWebsites:
                self.dismiss()
            }
        }
    }
}
