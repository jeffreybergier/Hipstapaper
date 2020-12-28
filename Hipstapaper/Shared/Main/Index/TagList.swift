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
import Combine
import Datum
import Localize

fileprivate class TagController: ObservableObject {
    
    let objectWillChange: ObservableObjectPublisher
    
    let staticTags = Query.Archived.anyTag_allCases
    let allTags: AnyList<AnyElement<AnyTag>>
    
    init(controller: Controller) throws {
        let tags = try controller.readTags().get()
        self.objectWillChange = tags.objectWillChange
        self.allTags = tags
    }
}

struct TagList: View {
    
    typealias Navigation = (AnyElement<AnyTag>) -> AnyView
    
    @ObservedObject private var controller: TagController
    @State private var selection: AnyElement<AnyTag>?
    private let navigation: Navigation
    
    init(controller: Controller, navigation: @escaping Navigation) throws {
        let tagController = try TagController(controller: controller)
        _controller = ObservedObject(initialValue: tagController)
        self.navigation = navigation
    }

    var body: some View {
        List(selection: self.$selection) {
            Section(header: Text.IndexSection(Noun.ReadingList)) {
                ForEach(self.controller.staticTags, id: \.self) { item in
                    NavigationLink(destination: self.navigation(item)) {
                        TagRow(item.value)
                    }
                }
            }
            Section(header: Text.IndexSection(Noun.Tags)) {
                ForEach(self.controller.allTags, id: \.self) { item in
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
