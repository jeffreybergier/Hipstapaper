//
//  Created by Jeffrey Bergier on 2024/01/13.
//
//  MIT License
//
//  Copyright (c) 2024 Jeffrey Bergier
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
import V3Store
import V3Style
import V3Localize

internal struct QRCode: View {
    
    private let selection: [Website.Selection.Element]
    
    internal init(_ selection: Website.Selection) {
        self.selection = Array(selection.sorted())
    }
    
    internal var body: some View {
        List(self.selection) { identifier in
            QRCodeRow(identifier)
        }
        .scrollContentBackground(self.scrollContentBackground)
    }
    
    private var scrollContentBackground: Visibility {
        #if os(macOS)
        return .hidden
        #else
        return .automatic
        #endif
    }
}

internal struct QRCodeRow: View {
    
    @WebsiteQuery private var query
    @V3Localize.WebsiteEdit private var text
    
    private let identifier: Website.Selection.Element
    
    internal init(_ identifier: Website.Selection.Element) {
        self.identifier = identifier
    }
    
    internal var body: some View {
        Section(self.title) {
            QRCodeImage(self.query.data?.preferredURL?.absoluteString)
        }
        .onChange(of: self.identifier, initial: true) { _, newValue in
            self.query.identifier = newValue
        }
    }
    
    private var title: String {
        self.query.data?.title ?? self.text.dataUntitled
    }
}

internal struct QRCodeImage: View {
    
    @V3Style.WebsiteEdit private var style
    @V3Localize.WebsiteEdit private var text
    @Environment(\.displayScale) private var displayScale

    private let input: String?
    
    internal init(_ input: String?) {
        self.input = input
    }
    
    internal var body: some View {
        self.image
    }
    
    @ViewBuilder private var image: some View {
        if
            let input,
            let qrcode = try? Image.QRCode(from: input, 
                                           size: self.style.QRCodeSize,
                                           displayScale: self.displayScale)
        {
            qrcode
        } else {
            self.style.disabled.action(text: self.text.noQRCode).label
        }
    }
}
