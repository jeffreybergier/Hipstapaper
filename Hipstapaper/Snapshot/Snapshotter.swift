//
//  Created by Jeffrey Bergier on 2020/12/05.
//
//  Copyright © 2020 Saturday Apps.
//
//  This file is part of Hipstapaper.
//
//  Hipstapaper is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Hipstapaper is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Hipstapaper.  If not, see <http://www.gnu.org/licenses/>.
//

import SwiftUI
import Combine
import Stylize
import Localize

public struct Snapshotter: View {
    
    @StateObject var viewModel: ViewModel
    
    public init(_ viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                FormSwitcher(viewModel: self.viewModel)
                    .paddingDefault_Equal(ignoring: [\.bottom])
                ZStack(alignment: .top) {
                    WebView(viewModel: self.viewModel)
                    WebThumbnail(viewModel: self.viewModel)
                }
                .frame(width: 300, height: 300)
                .cornerRadius_medium
                .paddingDefault_Equal(ignoring: [\.top])
            }
        }
        .modifier(STZ.MDL.Save(
            kind: STZ.TB.AddWebsite.self,
            cancel: { self.viewModel.doneAction(.failure(.userCancelled)) },
            save: { self.viewModel.doneAction(.success(self.viewModel.output)) },
            canSave: { self.viewModel.output.currentURL != nil }
        ))
    }
}

internal struct WebThumbnail: View {
    
    @ObservedObject var viewModel: ViewModel

    // TODO: Fix this
    var body: some View {
        let image: Imagable.Type = self.viewModel.formState == .load
            ? STZ.IMG.Web.self
            : STZ.IMG.WebError.self
        return image.thumbnail(self.viewModel.output.thumbnail?.value)
    }
}
