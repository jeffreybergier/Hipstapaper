//
//  Created by Jeffrey Bergier on 2022/04/08.
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
import Datum
import Localize
import Stylize

internal struct SingleWebsiteEdit: View {
    
    @WebsiteEditQuery private var website: Website
    @TagApplyQuery private var tags: AnyRandomAccessCollection<Datum.TagApply>
    @ControllerProperty private var controller
    
    private let mode: Mode
    private let onDone: Action
    
    @Localize private var text
    @ErrorQueue private var errorQ
    @StateObject private var control = Control()
    
    internal init(_ mode: Mode, _ ident: Website.Ident, onDone: @escaping Action) {
        _website = .init(id: ident)
        _tags = .init(selection: [ident])
        self.mode = mode
        self.onDone = onDone
    }
    
    internal var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                AutoloadForm(website: self.$website, control: self.control)
                    .modifier(STZ.PDG.Equal(ignore: [\.bottom]))
                Picture(website: self.$website, control: self.control)
                    .modifier(STZ.CRN.Medium.apply())
                    .modifier(STZ.PDG.Equal(ignore: [\.top]))
                if self.tags.isEmpty == false {
                    Section {
                        ForEach(self.$tags) {
                            TagApplyRow(value: $0)
                                .modifier(STZ.PDG.Default())
                        }
                    } header: {
                        Text(self.text.localized(key: Noun.applyTags.key))
                            .modifier(STZ.FNT.IndexRow.Title.apply())
                            .modifier(STZ.PDG.Default())
                    }
                }
            }
        }
        .if(.macOS) { $0.frame(width: 8*45, height: 8*56) }
        .modifier(STZ.MDL.DoneDelete(
            kind: self.mode == .add ? STZ.TB.AddWebsite.self : STZ.TB.EditWebsite.self,
            delete: self.onDelete,
            done: self.onDone)
        )
        .modifier(ErrorPresentation(self.$errorQ))
    }
    
    private func onDelete() {
        let error = DeleteError.website {
            switch self.controller.delete([self.website.uuid]) {
            case .success:
                self.onDone()
            case .failure(let error):
                self.errorQ = error
            }
        }
        self.errorQ = error
    }
}
