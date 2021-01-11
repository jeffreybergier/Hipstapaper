//
//  Created by Jeffrey Bergier on 2021/01/01.
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

struct DetailToolbar_iOS: ViewModifier {
    
    @ObservedObject var controller: WebsiteController
    @Binding var presentation: DetailToolbarPresentation.Wrap
    @Binding var popoverAlignment: Alignment
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private var isCompact: Bool {
        switch self.horizontalSizeClass ?? .compact {
        case .regular:
            return false
        case .compact:
            fallthrough
        @unknown default:
            return true
        }
    }
    
    func body(content: Content) -> some View {
        return self.isCompact
            ? AnyView(
                content.modifier(
                    DetailToolbar_Compact_iOS(
                        controller: self.controller,
                        presentation: self.$presentation,
                        popoverAlignment: self.$popoverAlignment
                    )
                )
            )
            : AnyView(
                content.modifier(
                    DetailToolbar_Regular_iOS(
                        controller: self.controller,
                        presentation: self.$presentation,
                        popoverAlignment: self.$popoverAlignment
                    )
                )
            )
    }
}

fileprivate struct DetailToolbar_Regular_iOS: ViewModifier {
    
    @ObservedObject var controller: WebsiteController
    @Binding var presentation: DetailToolbarPresentation.Wrap
    @Binding var popoverAlignment: Alignment
    
    @Environment(\.openURL) var openURL
    @Environment(\.editMode) var editMode
    
    func body(content: Content) -> some View {
        //
        // Bottom Buttons
        //
        let editModeModified: AnyView
        if self.editMode?.wrappedValue == .active {
            editModeModified = AnyView(
                //
                // In Edit More
                //
                content.toolbar(id: "Detail_iOS_Regular") {
                    ToolbarItem(id: "Detail_iOS_Regular.Archive", placement: .bottomBar) {
                        DT.Archive(isDisabled: self.controller.selectedWebsites.filter { !$0.value.isArchived }.isEmpty)
                        {
                            // Archive
                            let selected = self.controller.selectedWebsites
                            self.controller.selectedWebsites = []
                            try! self.controller.controller.update(selected, .init(isArchived: true)).get()
                        }
                    }
                    ToolbarItem(id: "Detail_iOS_Regular.Unarchive", placement: .bottomBar) {
                        DT.Unarchive(isDisabled: self.controller.selectedWebsites.filter { $0.value.isArchived }.isEmpty)
                        {
                            // Unarchive
                            let selected = self.controller.selectedWebsites
                            self.controller.selectedWebsites = []
                            try! self.controller.controller.update(selected, .init(isArchived: false)).get()
                        }
                    }
                    ToolbarItem(id: "Detail_iOS_Regular.Separator", placement: .bottomBar) {
                        ButtonToolbarSeparator()
                    }
                    ToolbarItem(id: "Detail_iOS_Regular.Tag", placement: .bottomBar) {
                        STZ.TB.TagApply.toolbarButton(isDisabled: self.controller.selectedWebsites.isEmpty)
                        {
                            self.popoverAlignment = .bottomLeading
                            self.presentation.value = .tagApply
                        }
                    }
                    ToolbarItem(id: "Detail_iOS_Regular.Spacer", placement: .bottomBar) {
                        Spacer()
                    }
                    ToolbarItem(id: "Detail_iOS_Regular.OpenExternal", placement: .bottomBar) {
                        DT.OpenExternal(selectionCount: self.controller.selectedWebsites.count) {
                            let urls = self.controller.selectedWebsites
                                .compactMap { $0.value.preferredURL }
                            urls.forEach { self.openURL($0) }
                        }
                    }
                    ToolbarItem(id: "Detail_iOS_Regular.Share", placement: .bottomBar) {
                        DT.Share(isDisabled: self.controller.selectedWebsites.isEmpty)
                        {
                            self.popoverAlignment = .bottomTrailing
                            self.presentation.value = .share
                        }
                    }
                    ToolbarItem(id: "Detail_iOS_Regular.Separator", placement: .bottomBar) {
                        ButtonToolbarSeparator()
                    }
                    ToolbarItem(id: "Detail_iOS_Regular.EditButton", placement: .bottomBar) {
                        EditButton()
                    }
                }
            )
        } else {
            //
            // Not in Edit More
            //
            editModeModified = AnyView(
                content.toolbar(id: "Detail_iOS_Regular") {
                    ToolbarItem(id: "Detail_iOS_Regular.Spacer", placement: .bottomBar) {
                        Spacer()
                    }
                    ToolbarItem(id: "Detail_iOS_Regular.EditButton", placement: .bottomBar) {
                        EditButton()
                    }
                }
            )
        }
        
        //
        // Top Bar Items
        //
        return editModeModified
            .toolbar(id: "Detail_iOS_Regular") {
                ToolbarItem(id: "Detail_iOS_Regular.Filter", placement: .automatic) {
                    DT.Filter(filter: self.controller.query.isArchived) {
                        self.popoverAlignment = .topTrailing
                        self.controller.query.isArchived.toggle()
                    }
                }
                ToolbarItem(id: "Detail_iOS_Regular.Sort", placement: .automatic) {
                    ButtonToolbarSort {
                        self.popoverAlignment = .topTrailing
                        self.presentation.value = .sort
                    }
                }
                ToolbarItem(id: "Detail_iOS_Regular.Search", placement: .primaryAction) {
                    DT.Search(searchActive: self.controller.query.search.nonEmptyString != nil) {
                        self.popoverAlignment = .topTrailing
                        self.presentation.value = .search
                    }
                }
            }
    }
}

fileprivate struct DetailToolbar_Compact_iOS: ViewModifier {
    
    @ObservedObject var controller: WebsiteController
    @Binding var presentation: DetailToolbarPresentation.Wrap
    @Binding var popoverAlignment: Alignment
    
    @Environment(\.openURL) var openURL
    @Environment(\.editMode) var editMode
    
    func body(content: Content) -> some View {
        //
        // Bottom Buttons
        //
        let editModeModified: AnyView
        if self.editMode?.wrappedValue == .active {
            //
            // In Edit More
            //
            editModeModified = AnyView(
                content.toolbar(id: "Detail_iOS_Compact") {
                    //
                    // Bottom Buttons
                    //
                    ToolbarItem(id: "Detail_iOS_Compact.Filter", placement: .bottomBar) {
                        DT.Filter(filter: self.controller.query.isArchived) {
                            self.popoverAlignment = .bottomLeading
                            self.controller.query.isArchived.toggle()
                        }
                    }
                    ToolbarItem(id: "Detail_iOS_Compact.Sort", placement: .bottomBar) {
                        ButtonToolbarSort {
                            self.popoverAlignment = .bottomLeading
                            self.presentation.value = .sort
                        }
                    }
                    ToolbarItem(id: "Detail_iOS_Compact.Separator", placement: .bottomBar) {
                        ButtonToolbarSeparator()
                    }
                    ToolbarItem(id: "Detail_iOS_Compact.Archive", placement: .bottomBar) {
                        DT.Archive(isDisabled: self.controller.selectedWebsites.filter { !$0.value.isArchived }.isEmpty)
                        {
                            // Archive
                            let selected = self.controller.selectedWebsites
                            self.controller.selectedWebsites = []
                            try! self.controller.controller.update(selected, .init(isArchived: true)).get()
                        }
                    }
                    ToolbarItem(id: "Detail_iOS_Compact.Unarchive", placement: .bottomBar) {
                        DT.Unarchive(isDisabled: self.controller.selectedWebsites.filter { $0.value.isArchived }.isEmpty)
                        {
                            // Unarchive
                            let selected = self.controller.selectedWebsites
                            self.controller.selectedWebsites = []
                            try! self.controller.controller.update(selected, .init(isArchived: false)).get()
                        }
                    }
                    ToolbarItem(id: "Detail_iOS_Compact.Tag", placement: .bottomBar) {
                        STZ.TB.TagApply.toolbarButton(isDisabled: self.controller.selectedWebsites.isEmpty)
                        {
                            self.popoverAlignment = .bottomLeading
                            self.presentation.value = .tagApply
                        }
                    }
                    ToolbarItem(id: "Detail_iOS_Compact.Separator", placement: .bottomBar) {
                        ButtonToolbarSeparator()
                    }
                    ToolbarItem(id: "Detail_iOS_Compact.OpenExternal", placement: .bottomBar) {
                        DT.OpenExternal(selectionCount: self.controller.selectedWebsites.count) {
                            let urls = self.controller.selectedWebsites
                                .compactMap { $0.value.preferredURL }
                            urls.forEach { self.openURL($0) }
                        }
                    }
                    ToolbarItem(id: "Detail_iOS_Compact.Spacer", placement: .bottomBar) {
                        Spacer()
                    }
                    ToolbarItem(id: "Detail_iOS_Compact.EditButton", placement: .bottomBar) {
                        EditButton()
                    }
                }
            )
        } else {
            //
            // Not in Edit More
            //
            editModeModified = AnyView(
                content.toolbar(id: "Detail_iOS_Compact") {
                    ToolbarItem(id: "Detail_iOS_Compact.Spacer", placement: .bottomBar) {
                        Spacer()
                    }
                    ToolbarItem(id: "Detail_iOS_Compact.EditButton", placement: .bottomBar) {
                        // TODO: Clear selection when leaving edit mode
                        EditButton()
                    }
                }
            )
        }
        return editModeModified
            .toolbar(id: "Detail_iOS_Compact") {
                //
                // Top Bar Items
                //
                ToolbarItem(id: "Detail_iOS_Compact.Share", placement: .cancellationAction) {
                    DT.Share(isDisabled: self.controller.selectedWebsites.isEmpty)
                    {
                        self.popoverAlignment = .topLeading
                        self.presentation.value = .share
                    }
                }
                ToolbarItem(id: "Detail_iOS_Compact.Search", placement: .primaryAction) {
                    DT.Search(searchActive: self.controller.query.search.nonEmptyString != nil) {
                        self.popoverAlignment = .topTrailing
                        self.presentation.value = .search
                    }
                }
            }
    }
}
