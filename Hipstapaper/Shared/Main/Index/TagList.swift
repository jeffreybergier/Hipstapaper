//
//  Created by Jeffrey Bergier on 2020/11/30.
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

struct TagList: View {
    
    typealias Navigation = (AnyElement<AnyTag>) -> AnyView
    
    @ObservedObject private var controller: TagController
    private let navigation: Navigation
    
    init(controller: Controller, navigation: @escaping Navigation) {
        let tagController = TagController(controller: controller)
        _controller = ObservedObject(initialValue: tagController)
        self.navigation = navigation
    }
    
    init(controller: TagController, navigation: @escaping Navigation) {
        _controller = ObservedObject(initialValue: controller)
        self.navigation = navigation
    }

    var body: some View {
        List(selection: self.$controller.selection) {
            Section(header: Text.IndexSection(Noun.ReadingList)) {
                ForEach(self.controller.`static`, id: \.self) { item in
                    NavigationLink(destination: self.navigation(item)) {
                        TagRow(item.value)
                    }
                }
            }
            Section(header: Text.IndexSection(Noun.Tags)) {
                ForEach(self.controller.all, id: \.self) { item in
                    NavigationLink(destination: self.navigation(item)) {
                        TagRow(item.value)
                    }
                }
            }
        }
        .listStyle(SidebarListStyle())
        .navigationTitle(Noun.Tags)
    }
}

#if DEBUG
struct TagList_Preview: PreviewProvider {
    static var previews: some View {
        try! TagList(controller: P_Controller(), navigation: { _ in AnyView(Text("Swift Previews")) })
    }
}
#endif
