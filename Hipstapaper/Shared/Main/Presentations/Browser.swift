//
//  Created by Jeffrey Bergier on 2021/01/07.
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

import Combine
import Datum
import SwiftUI
import Browse

class BrowserPresentation: ObservableObject {
    @Published var item: AnyElement<AnyWebsite>! {
        didSet {
            self.isPresented = self.item != nil
        }
    }
    @Published var isPresented: Bool = false {
        didSet {
            switch self.isPresented {
            case true:
                assert(self.item != nil)
            case false:
                guard self.item != nil else { return }
                self.item = nil
            }
        }
    }
}

struct BrowserPresentable: ViewModifier {
    
    @EnvironmentObject private var presentation: BrowserPresentation
    
    func body(content: Content) -> some View {
        content.sheet(isPresented: self.$presentation.isPresented) {
            Browser(url: self.presentation.item.value.preferredURL!,
                    doneAction: { self.presentation.item = nil })
        }
    }
}
