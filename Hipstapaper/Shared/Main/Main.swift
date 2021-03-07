//
//  Created by Jeffrey Bergier on 2020/11/23.
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
import Stylize

struct Main: View {
    
    let controller: Controller
    
    @StateObject private var errorQ = ErrorQueue()
    @StateObject private var modalPresentation = ModalPresentation.Wrap()
    @StateObject private var websiteControllerCache = Cache<AnyElementObserver<AnyTag>, WebsiteDataSource>()

    init(controller: Controller) {
        self.controller = controller
    }
    
    var body: some View {
        NavigationView {
            TagList(controller: self.controller) { selectedTag in
                WebsiteList(dataSource: self.websiteControllerCache[selectedTag] {
                    WebsiteDataSource(controller: self.controller,
                                      selectedTag: selectedTag)
                })
            }
            // TODO: Has to be here because of macOS bug
            .modifier(ErrorQueuePresenter())
        }
        .modifier(BrowserPresentable())
        .environmentObject(self.modalPresentation)
        .environmentObject(self.errorQ)
    }
}

#if DEBUG
struct Main_Previews: PreviewProvider {
    static var previews: some View {
        Main(controller: P_Controller())
    }
}
#endif
