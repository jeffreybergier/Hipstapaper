//
//  Created by Jeffrey Bergier on 2021/02/05.
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
import Stylize

typealias WH = WebsiteHelper

enum WebsiteHelper {
    
    typealias Selection = Set<AnyElementObserver<AnyWebsite>>
    
    static func canShare(_ selection: Selection) -> Bool {
        return selection.first(where: { $0.value.preferredURL != nil }) != nil
    }
    static func canTag(_ selection: Selection) -> Bool {
        return selection.isEmpty == false
    }
    static func canArchive(_ selection: Selection) -> Bool {
        return selection.first(where: { $0.value.isArchived == false }) != nil
    }
    static func canUnarchive(_ selection: Selection) -> Bool {
        return selection.first(where: { $0.value.isArchived == true }) != nil
    }
    static func canDelete(_ selection: Selection) -> Bool {
        return selection.isEmpty == false
    }
    static func canOpen(_ selection: Selection, in wm: WindowPresentation) -> Bool {
        if wm.features.contains(.bulkActivation) {
            return selection.first(where: { $0.value.preferredURL != nil }) != nil
        } else {
            return selection.compactMap { $0.value.preferredURL != nil }.count == 1
        }
    }
    
    static func archive(_ selection: Selection, _ controller: Controller, _ errorQ: ErrorQueue) {
        let result = controller.update(selection, .init(isArchived: true))
        result.error.map {
            errorQ.queue.append($0)
            log.error($0)
        }
    }
    
    static func unarchive(_ selection: Selection, _ controller: Controller, _ errorQ: ErrorQueue) {
        let result = controller.update(selection, .init(isArchived: false))
        result.error.map {
            errorQ.queue.append($0)
            log.error($0)
        }
    }
    
    static func delete(_ selection: Selection, _ controller: Controller, _ errorQ: ErrorQueue) {
        let result = controller.delete(selection)
        result.error.map {
            errorQ.queue.append($0)
            log.error($0)
        }
    }
    
    static func open(_ selection: Selection, in open: OpenURLAction) {
        selection
            .compactMap { $0.value.preferredURL }
            .forEach { open($0) }
    }
    
    @discardableResult
    /// Item returned if device not capable of window presentation
    static func open(_ selection: Selection, in wm: WindowPresentation, _ errorQ: ErrorQueue) -> AnyElementObserver<AnyWebsite>? {
        guard selection.isEmpty == false else { return nil }
        let urls = selection.compactMap { $0.value.preferredURL }
        
        guard urls.isEmpty == false else { fatalError("Maybe present an error?") }
        guard wm.features.contains([.multipleWindows, .bulkActivation])
            else { return selection.first! }
        
        wm.show(Set(urls))
        return nil
    }
    
    @ViewBuilder static func filterToolbarItem(_ query: Query,
                                               action: @escaping () -> Void) -> some View
    {
        if query.filter.boolValue {
            // disable this when there is no tag selected
            STZ.TB.FilterActive.toolbar(isEnabled: query.tag != nil, action: action)
        } else {
            // disable this when there is no tag selected
            STZ.TB.FilterInactive.toolbar(isEnabled: query.tag != nil, action: action)
        }
    }
    
    @ViewBuilder static func searchToolbarItem(_ query: Query,
                                               action: @escaping () -> Void) -> some View
    {
        if query.isSearchActive {
            STZ.TB.SearchInactive.toolbar(action: action)
        } else {
            STZ.TB.SearchActive.toolbar(action: action)
        }
    }
}
