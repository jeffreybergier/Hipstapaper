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

struct Toolbar: View {
    
    @ObservedObject var controller: AnyUIController
    
    var body: some View {
        HStack {
            Button(action: {
                print("Archive")
            }, label: {
                Image(systemName: "tray.and.arrow.down")
            }).disabled(self.controller.selectedWebsite?.isArchived ?? true)
            Button(action: {
                print("Unarchive")
            }, label: {
                Image(systemName: "tray.and.arrow.up")
            }).disabled(!(self.controller.selectedWebsite?.isArchived ?? false))
            Button(action: {
                print("Tag")
            }, label: {
                Image(systemName: "tag")
            }).disabled(self.controller.selectedWebsite == nil)
            Button(action: {
                print("Share")
            }, label: {
                Image(systemName: "square.and.arrow.up")
            }).disabled(self.controller.selectedWebsite == nil)
            Button(action: {
                print("Search")
            }, label: {
                Image(systemName: "magnifyingglass")
            })
        }
    }
    
}
