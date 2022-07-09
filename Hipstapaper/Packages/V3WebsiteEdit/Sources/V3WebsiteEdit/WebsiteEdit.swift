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

public struct WebsiteEdit: View {
    
    public enum Screen {
        case website
        case tag
    }
        
    @StateObject private var nav = Nav.newEnvironment()
    @State private var screen: Screen
    
    private let selection: Website.Selection
    
    public init(selection: Website.Selection, start screen: Screen) {
        self.selection = selection
        _screen = .init(initialValue: screen)
    }
    
    public var body: some View {
        TabView(selection: self.$screen) {
            FormParent(self.selection)
                .tag(Screen.website)
                .tabItem {
                    Label("Website(s)", systemImage: "doc.richtext")
                }
            TagApply(self.selection)
                .frame(idealWidth: 320, idealHeight: 480)
                .tag(Screen.tag)
                .tabItem {
                    Label("Tags", systemImage: "tag")
                }
        }
        .environmentObject(self.nav)
        .frame(idealWidth: self.idealWidth, idealHeight: self.idealHeight)
    }
    
    private var idealWidth: CGFloat {
        switch self.screen {
        case .website: return 480
        case .tag: return 320
        }
    }
    
    private var idealHeight: CGFloat {
        switch self.screen {
        case .website: return 720
        case .tag: return 480
        }
    }
    
}
