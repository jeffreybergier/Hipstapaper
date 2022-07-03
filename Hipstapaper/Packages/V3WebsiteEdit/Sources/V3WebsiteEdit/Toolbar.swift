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
import V3Style
import V3Localize

internal struct Toolbar: ViewModifier {
    
    @Nav private var nav
    @V3Style.Browser private var style
    @V3Localize.Browser private var text
    @Environment(\.dismiss) private var dismiss
    
    private var selection: Website.Selection
    
    internal init(_ selection: Website.Selection) {
        self.selection = selection
    }
        
    internal func body(content: Content) -> some View {
        content
            .navigationTitle("Edit Website(s)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarRole(.navigationStack)
            .toolbar {
                ToolbarItem(id: .itemErrors, placement: .primaryAction) {
                    self.itemErrors
                }
                ToolbarItem(id: .itemClose, placement: .primaryAction) {
                    self.itemClose
                }
                ToolbarItem(id: .itemClose, placement: .cancellationAction) {
                    self.itemDelete
                }
                if self.selection.count == 1 {
                    ToolbarItem(id: .itemSpacer1, placement: .bottomBar) {
                        self.itemSpacer
                    }
                    ToolbarItem(id: .itemJavaScript, placement: .bottomBar) {
                        self.itemJavaScript
                    }
                    ToolbarItem(id: .itemSeparator1, placement: .bottomBar) {
                        self.itemSeparator
                    }
                    ToolbarItem(id: .itemStopReload, placement: .bottomBar) {
                        self.itemStopReload
                    }
                }
            }
    }
    
    private var itemStopReload: some View {
        if self.nav.isLoading {
            return self.style.stop.button(self.text.stop) {
                self.nav.shouldStop = true
            }
        } else {
            return self.style.reload.button(self.text.reload) {
                self.nav.shouldReload = true
            }
        }
    }
    
    private var itemJavaScript: some View {
        if self.nav.isJSEnabled {
            return self.style.jsYes.button(self.text.jsYes) {
                self.nav.isJSEnabled = false
            }
        } else {
            return self.style.jsNo.button(self.text.jsNo) {
                self.nav.isJSEnabled = true
            }
        }
    }
    
    @ViewBuilder private var itemErrors: some View {
        if self.nav.errorQueue.isEmpty == false {
            self.style.error.button(self.text.error) {
                self.nav.isErrorList.isPresented = true
            }
            .modifier(ErrorListPresentation())
        }
    }
    
    private var itemClose: some View {
        Button(self.text.done) {
            self.dismiss()
        }
    }
    
    private var itemDelete: some View {
        Button("DDelete") {
            
        }
    }
    
    private var itemSpacer: some View {
        Spacer()
    }
    
    private var itemSeparator: some View {
        Text("|")
    }
}

extension String {
    fileprivate static let itemStopReload      = "toolbar.stopreload"
    fileprivate static let itemJavaScript      = "toolbar.javascript"
    fileprivate static let itemClose           = "toolbar.close"
    fileprivate static let itemErrors          = "toolbar.errors"
    fileprivate static let itemSpacer1         = "toolbar.spacer1"
    fileprivate static let itemSeparator1      = "toolbar.separator1"
}
