//
//  Created by Jeffrey Bergier on 2020/12/08.
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
import Localize

struct SnapshotToolbar: View {
    
    @ObservedObject var output: WebView.Output
    let cancel: () -> Void
    let confirm: () -> Void
    
    var body: some View {
        Toolbar {
            HStack {
                Button.Default("Cancel", action: self.cancel)
                    .keyboardShortcut(.escape)
                Spacer()
                Text("Add Website")
                    .font(.title3)
                Spacer()
                Button.Done(Save, action: self.confirm)
                    .keyboardShortcut(.defaultAction)
                    .disabled(
                        URL(string: self.output.resolvedURLString) == nil
                            || self.output.title.isEmpty
                    )
            }
        }
    }
}
