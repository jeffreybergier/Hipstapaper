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
import Datum
import Localize
import Stylize

struct IndexToolbar: View {
    
    @ObservedObject var controller: AnyUIController
    @State var presentation: Presentation.Wrap
    
    var body: some View {
        HStack {
            ToolbarButton(systemName: "minus",
                          accessibilityLabel: DeleteTag)
            {
                // Delete
                guard let tag = self.controller.selectedTag else { return }
                let element = AnyElement(StaticElement(tag))
                try! self.controller.controller.delete(element).get()
            }
            .disabled({
                guard let tag = self.controller.selectedTag else { return true }
                return tag.wrappedValue as? Query.Archived != nil
            }())
            
            ToolbarButton(systemName: "plus",
                          accessibilityLabel: AddTag)
            {
                self.presentation.value = .addTag
            }
            .popover(isPresented: self.$presentation.isAddTag, content: {
                Text("Add Tag!")
            })
        }
    }
    
}
