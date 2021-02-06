//
//  Created by Jeffrey Bergier on 2021/02/05.
//
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
    static func isFiltered(_ query: Query) -> Bool {
        return query.isArchived.boolValue
    }
    static func isSearchActive(_ query: Query) -> Bool {
        return query.search.nonEmptyString == nil
    }
    
    static func archive(_ selection: Selection, _ controller: Controller, _ errorQ: ErrorQ) {
        let r = errorQ.append(controller.update(selection, .init(isArchived: true)))
        log.error(r.error)
    }
    
    static func unarchive(_ selection: Selection, _ controller: Controller, _ errorQ: ErrorQ) {
        let r = errorQ.append(controller.update(selection, .init(isArchived: false)))
        log.error(r.error)
    }
    
    static func delete(_ selection: Selection, _ controller: Controller, _ errorQ: ErrorQ) {
        let r = errorQ.append(controller.delete(selection))
        log.error(r.error)
    }
    
    static func open(_ selection: Selection, in open: OpenURLAction) {
        selection
            .compactMap { $0.value.preferredURL }
            .forEach { open($0) }
    }
    
    @discardableResult
    /// Item returned if device not capable of window presentation
    static func open(_ selection: Selection, in wm: WindowPresentation, _ errorQ: ErrorQ) -> AnyElementObserver<AnyWebsite>? {
        guard selection.isEmpty == false else { return nil }
        let urls = selection.compactMap { $0.value.preferredURL }
        
        guard urls.isEmpty == false else { fatalError("Maybe present an error?") }
        guard wm.features.contains([.multipleWindows, .bulkActivation])
            else { return selection.first! }
        
        wm.show(Set(urls)) { errorQ.append($0) }
        return nil
    }
}
