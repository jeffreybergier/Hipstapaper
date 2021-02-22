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
import Umbrella
import Stylize

public struct Browser: View {
    
    @StateObject public var viewModel: ViewModel
    @StateObject private var errorQ = ErrorQueue()
    
    public var body: some View {
        ZStack(alignment: .top) {
            WebView(viewModel: self.viewModel)
                .frame(minWidth: 300, idealWidth: 768, minHeight: 300, idealHeight: 768)
                .edgesIgnoringSafeArea(.all)
            Color.clear // needed so the progress bar doesn't also ignore safe areas
                .modifier(STZ.PRG.BarMod(progress: self.viewModel.browserDisplay.progress,
                                         isVisible: self.viewModel.browserDisplay.isLoading))
        }
        .onAppear() {
            guard self.viewModel.originalURL == nil else { return }
            self.errorQ.queue.append(Error.loadURL)
        }
        // TODO: Toolbar leaks like crazy on iOS :(
        .modifier(Toolbar(viewModel: self.viewModel))
        .modifier(ErrorQueuePresenter())
        .environmentObject(self.errorQ)
    }
    
    public init(_ viewModel: ViewModel) {
        _viewModel = .init(wrappedValue: viewModel)
    }
    
    public init(url: URL?, doneAction: (() -> Void)?) {
        _viewModel = .init(wrappedValue: .init(url: url, doneAction: doneAction))
    }
}
