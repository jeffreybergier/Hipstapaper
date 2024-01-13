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

internal struct QRCode: View {
    
    private let selection: [Website.Selection.Element]
    
    internal init(_ selection: Website.Selection) {
        self.selection = Array(selection.sorted())
    }
    
    internal var body: some View {
        ScrollView {
            ForEach(self.selection) { identifier in
                QRCodeImage(identifier)
            }
        }
    }
}

internal struct QRCodeImage: View {
    
    @WebsiteQuery private var query
    @Environment(\.displayScale) private var displayScale

    private let identifier: Website.Selection.Element
    
    internal init(_ identifier: Website.Selection.Element) {
        self.identifier = identifier
    }
    
    internal var body: some View {
        Group {
            if let image {
                image
            } else {
                // TODO: Replace with placholder
                Color.red
            }
        }
        .onChange(of: self.identifier, initial: true) { _, newValue in
            self.query.identifier = newValue
        }
    }
    
    private var image: Image? {
        guard let url = self.query.data?.preferredURL else { return nil }
        do {
            return try Image.QRCode(from: url.absoluteString, size: 512, displayScale: self.displayScale)
        } catch {
            print(String(describing: error))
            return nil
        }
    }
}
