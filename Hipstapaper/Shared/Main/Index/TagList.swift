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
import Umbrella
import Datum
import Localize
import Stylize

struct TagList<Nav: View>: View {
    
    typealias Navigation = (AnyElementObserver<AnyTag>) -> Nav
    
    @State private var selection: TH.Selection?
    @State private var initialSelection = true
    @StateObject private var dataSource: TagDataSource
    @EnvironmentObject private var errorQ: ErrorQueue

    private let navigation: Navigation
    
    init(controller: Controller, @ViewBuilder navigation: @escaping Navigation) {
        self.navigation = navigation
        _dataSource = .init(wrappedValue: TagDataSource(controller: controller))
    }

    var body: some View {
        List(selection: self.$selection) {
            Section(header: STZ.VIEW.TXT(Noun.ReadingList)
                        .modifier(STZ.CLR.IndexSection.Text.foreground())
                        .modifier(STZ.FNT.IndexSection.Title.apply()))
            {
                let item0 = Query.Filter.anyTag_allCases[0]
                let item1 = Query.Filter.anyTag_allCases[1]
                NavigationLink(destination: self.navigation(item0),
                               isActive: self.$initialSelection)
                {
                    TagRow(item: item0)
                        .environment(\.XPL_isSelected, self.selection == item0)
                }
                NavigationLink(destination: self.navigation(item1)) {
                    TagRow(item: item1)
                        .environment(\.XPL_isSelected, self.selection == item1)
                }
            }
            Section(header: STZ.VIEW.TXT(Noun.Tags)
                        .modifier(STZ.CLR.IndexSection.Text.foreground())
                        .modifier(STZ.FNT.IndexSection.Title.apply()))
            {
                ForEach(self.dataSource.data, id: \.self) { item in
                    NavigationLink(destination: self.navigation(item)) {
                        TagRow(item: item)
                            .environment(\.XPL_isSelected, self.selection == item)
                            .modifier(TagMenu(controller: self.dataSource.controller, selection: item))
                    }
                }
            }
        }
        .navigationTitle(Noun.Tags)
        .modifier(SidebarStyle())
        .modifier(IndexToolbar(controller: self.dataSource.controller,
                               selection: self.$selection))
        .onAppear() { self.dataSource.activate(self.errorQ) }
        .onDisappear(perform: self.dataSource.deactivate)
    }
}

#if DEBUG
struct TagList_Preview: PreviewProvider {
    static var previews: some View {
        TagList(controller: P_Controller(),
                navigation: { _ in STZ.VIEW.TXT("Swift Previews") })
    }
}
#endif

fileprivate struct SidebarStyle: ViewModifier {
    #if os(macOS)
    func body(content: Content) -> some View {
        content.listStyle(SidebarListStyle())
    }
    #else
    @ViewBuilder func body(content: Content) -> some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            content.listStyle(SidebarListStyle())
        } else {
            content.listStyle(InsetGroupedListStyle())
        }
    }
    #endif
}
