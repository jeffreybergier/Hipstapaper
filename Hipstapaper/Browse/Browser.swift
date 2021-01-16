//
//  Created by Jeffrey Bergier on 2020/12/20.
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
import Stylize

public struct Browser: View {
    
    @StateObject public var viewModel: ViewModel
    @StateObject private var errorQ = STZ.ERR.Q()
    
    public var body: some View {
        ZStack(alignment: .top) {
            WebView(viewModel: self.viewModel)
                .frame(minWidth: 300, idealWidth: 768, minHeight: 300, idealHeight: 768)
                .edgesIgnoringSafeArea(.all)
            if self.viewModel.browserDisplay.isLoading {
                STZ.PRG.Bar(self.viewModel.browserDisplay.progress)
                    .opacity(self.viewModel.browserDisplay.isLoading ? 1 : 0)
            }
        }
        // TODO: Toolbar leaks like crazy on iOS :(
        .modifier(Toolbar(viewModel: self.viewModel))
        .modifier(STZ.ERR.QPresenter(self.errorQ))
        .environmentObject(self.errorQ)
    }
    
    public init(_ viewModel: ViewModel) {
        _viewModel = .init(wrappedValue: viewModel)
    }
    
    public init(url: URL, doneAction: (() -> Void)?) {
        _viewModel = .init(wrappedValue: .init(url: url, doneAction: doneAction))
    }
}
