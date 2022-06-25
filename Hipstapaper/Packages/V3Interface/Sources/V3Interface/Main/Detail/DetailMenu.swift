//
//  Created by Jeffrey Bergier on 2022/06/23.
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
import V3Model
import V3Style
import V3Localize

extension ViewModifier where Self == DetailMenu {
    internal static var detailMenu: Self { Self.init() }
}

internal struct DetailMenu: ViewModifier {

    @Nav private var nav
    @V3Style.DetailToolbar private var style
    @V3Localize.DetailToolbar private var text
    
    // TODO: Add Data Controller
        
    internal func body(content: Content) -> some View {
        content
            .contextMenu(forSelectionType: Website.Selection.Element.self) { items in
                Text("\(items.count) selected")
                self.style.openInApp.button(self.text.openInApp,
                                            enabled: items.count == 1)
                {
                    self.nav.detail.isBrowse = items.first
                }
                self.style.openExternal.button(self.text.openExternal) {
                    
                }
                self.style.archiveYes.button(self.text.archiveYes,
                                             enabled: false)
                {
                    
                }
                self.style.archiveNo.button(self.text.archiveNo,
                                            enabled: false)
                {
                    
                }
                self.style.share.button(self.text.share) {
                    
                }
                self.style.applyTags.button(self.text.applyTags) {
                    self.nav.detail.isApplyTags = items
                }
                self.style.edit.button(self.text.edit) {
                    
                }
                self.style.delete.button(self.text.edit) {
                    
                }
            }
    }
}
