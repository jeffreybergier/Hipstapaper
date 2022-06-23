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

extension ViewModifier where Self == DetailMenu {
    internal static var detailMenu: Self { Self.init() }
}

internal struct DetailMenu: ViewModifier {

    @Nav private var nav
    @V3Style.DetailMenu private var style
    
    internal func body(content: Content) -> some View {
        content
            .contextMenu(forSelectionType: Website.Selection.Element.self) { items in
                Text("\(items.count) selected")
                self.style.openInApp.button("Open") {
                    
                }
                self.style.openExternal.button("Open in Browser") {
                    
                }
                self.style.archiveYes.button("Archive", enabled: true) {
                    
                }
                self.style.archiveNo.button("Unarchive", enabled: false) {
                    
                }
                self.style.share.button("Share") {
                    
                }
                self.style.applyTags.button("Apply Tags") {
                    
                }
                self.style.edit.button("Edit") {
                    
                }
                self.style.delete.button("Delete") {
                    
                }
            }
    }
}
