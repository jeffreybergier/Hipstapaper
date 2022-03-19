//
//  Created by Jeffrey Bergier on 2020/11/30.
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
import Datum2
import Stylize
import Localize

struct WebsiteRow: View {
    
    private static let formatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .long
        df.timeStyle = .short
        return df
    }()
    
    @Localize private var text
    
    var item: Website
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                STZ.VIEW.TXT(self.item.title, or: Noun.untitled.loc(self.text))
                    .modifier(STZ.FNT.DetailRow.Title.apply())
                    .modifier(STZ.CLR.DetailRow.Text.foreground())
                STZ.VIEW.TXT(WebsiteRow.formatter.string(from: self.item.dateCreated))
                    .modifier(STZ.FNT.DetailRow.Subtitle.apply())
                    .modifier(STZ.CLR.DetailRow.Text.foreground())
            }
            Spacer()
            STZ.ICN.placeholder.thumbnail(self.item.thumbnail)
                .frame(width: 60)
        }
        .frame(minHeight: 60)
    }
}
