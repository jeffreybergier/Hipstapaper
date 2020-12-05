//
//  Created by Jeffrey Bergier on 2020/12/03.
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
import Snapshot

struct DetailToolbar: View {
    
    @ObservedObject var controller: AnyUIController
    @State var presentation: Presentation.Wrap

    var body: some View {
        HStack {
            Button(action: {
                // Add
                self.presentation.value = .addWebsite
            }, label: {
                Image(systemName: "plus")
            })
            .sheet(isPresented: self.$presentation.isAddWebsite, content: {
                Snapshotter()
            })
            
            Button(action: {
                // Archive
                guard let site = self.controller.selectedWebsite else { return }
                let element = AnyElement(StaticElement(site))
                try! self.controller.controller.update(element, .init(isArchived: true)).get()
            }, label: {
                Image(systemName: "tray.and.arrow.down")
            })
            .disabled(self.controller.selectedWebsite?.isArchived ?? true)
            
            Button(action: {
                // Unarchive
                guard let site = self.controller.selectedWebsite else { return }
                let element = AnyElement(StaticElement(site))
                try! self.controller.controller.update(element, .init(isArchived: false)).get()
            }, label: {
                Image(systemName: "tray.and.arrow.up")
            })
            .disabled(!(self.controller.selectedWebsite?.isArchived ?? false))
            
            Button(action: {
                print("Tag")
                self.presentation.value = .tagApply
            }, label: {
                Image(systemName: "tag")
            })
            .disabled(self.controller.selectedWebsite == nil)
            .popover(isPresented: self.$presentation.isTagApply, content: {
                Text("Tag!")
            })
            
            Button(action: {
                print("Share")
                self.presentation.value = .share
            }, label: {
                Image(systemName: "square.and.arrow.up")
            })
            .disabled(self.controller.selectedWebsite == nil)
            .sheet(isPresented: self.$presentation.isShare, content: {
                Text("Share!")
            })
            
            Button(action: {
                print("Search")
                self.presentation.value = .search
            }, label: {
                // TODO: Make search look different when a search is in effect
                // self.controller.detailQuery.search.nonEmptyString == nil
                Image(systemName: "magnifyingglass")
            })
            .popover(isPresented: self.$presentation.isSearch, content: {
                Search(search: self.$controller.detailQuery.search)
            })
        }
    }
    
}
