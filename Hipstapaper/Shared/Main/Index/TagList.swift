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
import Stylize

struct TagList<Nav: View>: View {
    
    typealias Navigation = (AnyElementObserver<AnyTag>) -> Nav
    
    @State private var selection: TH.Selection?
    @StateObject private var dataSource: TagDataSource
    @EnvironmentObject private var errorQ: STZ.ERR.ViewModel

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
                ForEach(Query.Filter.anyTag_allCases, id: \.self) { item in
                    NavigationLink(destination: self.navigation(item)) {
                        TagRow(item: item)
                            .animation(nil)
                    }
                }
            }
            Section(header: STZ.VIEW.TXT(Noun.Tags)
                        .modifier(STZ.CLR.IndexSection.Text.foreground())
                        .modifier(STZ.FNT.IndexSection.Title.apply()))
            {
                ForEach(self.dataSource.data, id: \.self) { item in
                    NavigationLink(destination: self.navigation(item)) {
                        TagRow(item: item)
                            .modifier(TagMenu(selection: item))
                    }
                }
            }
        }
        .animation(.default)
        .navigationTitle(Noun.Tags)
        .modifier(SidebarStyle())
        .modifier(IndexToolbar(controller: self.dataSource.controller,
                               selection: self.$selection))
        .onAppear() { self.errorQ.append(self.dataSource.activate()) }
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
