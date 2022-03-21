//
//  Created by Jeffrey Bergier on 2020/12/03.
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
import Datum
import Stylize
import Browse

enum DetailToolbar {
    struct Shared: ViewModifier {
        
        let controller: Controller
        @Binding var selection: WH.Selection
        @State private var popoverAlignment: Alignment = .topTrailing

        func body(content: Content) -> some View {
            return ZStack(alignment: self.popoverAlignment) {
                // TODO: Hack when toolbars work properly with popovers
                Color.clear.frame(width: 1, height: 1).modifier(
                    TagApplyPresentable(controller: self.controller)
                )
                Color.clear.frame(width: 1, height: 1).modifier(
                    SharePresentable()
                )
                Color.clear.frame(width: 1, height: 1).modifier(
                    SearchPickerPresentable()
                )
                Color.clear.frame(width: 1, height: 1).modifier(
                    SortPickerPresentable()
                )
                    
                #if os(macOS)
                content.modifier(macOS(selection: self.$selection))
                #else
                content.modifier(iOS.Shared(selection: self.$selection,
                                            popoverAlignment: self.$popoverAlignment))
                #endif
            }
        }
    }
}

struct ToolbarFilterIsEnabled: EnvironmentKey {
    static var defaultValue: Bool = true
}

extension EnvironmentValues {
    var toolbarFilterIsEnabled: Bool {
        get { self[ToolbarFilterIsEnabled.self] }
        set { self[ToolbarFilterIsEnabled.self] = newValue }
    }
}
