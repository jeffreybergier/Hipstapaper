//
//  Created by Jeffrey Bergier on 2020/12/28.
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

import Combine
import Datum

class WebsiteController: ObservableObject {
    
    let controller: Controller
    var all: AnyList<AnyElement<AnyWebsite>> {
        get {
            if let all = _all { return all }
            self.update()
            return _all ?? .empty
        }
    }
    @Published var selectedWebsites: Set<AnyElement<AnyWebsite>> = []
    @Published var query: Query {
        didSet {
            self.update()
        }
    }
    
    private var _all: AnyList<AnyElement<AnyWebsite>>? = nil
    private var token: AnyCancellable?
    
    init(controller: Controller, selectedTag: AnyElement<AnyTag> = Query.Archived.anyTag_allCases[0]) {
        self.query = Query(specialTag: selectedTag)
        self.controller = controller
    }
    
    private func update() {
        self.token?.cancel()
        self.token = nil
        let result = controller.readWebsites(query: self.query)
        switch result {
        case .failure(let error):
            // TODO: Do something with this error
            _all = nil
            break
        case .success(let sites):
            self._all = sites
            self.objectWillChange.send()
            self.token = sites.objectWillChange.sink { [unowned self] _ in
                self.objectWillChange.send()
            }
        }
    }
}

// MARK: Toolbar helpers
import SwiftUI
extension WebsiteController {
    func canShare() -> Bool {
        return self.selectedWebsites.first(where: { $0.value.preferredURL != nil }) != nil
    }
    func canTag() -> Bool {
        return self.selectedWebsites.isEmpty == false
    }
    func canArchive() -> Bool {
        return self.selectedWebsites.first(where: { $0.value.isArchived == false }) != nil
    }
    func canUnarchive() -> Bool {
        return self.selectedWebsites.first(where: { $0.value.isArchived == true }) != nil
    }
    func canOpen(in wm: WindowPresentation) -> Bool {
        if wm.features.contains(.bulkActivation) {
            return self.selectedWebsites.first(where: { $0.value.preferredURL != nil }) != nil
        } else {
            return self.selectedWebsites.compactMap { $0.value.preferredURL != nil }.count == 1
        }
    }
    func isFiltered() -> Bool {
        return self.query.isArchived.boolValue
    }
    func isSearchActive() -> Bool {
        return self.query.search.nonEmptyString == nil
    }
    func archive() {
        let selected = self.selectedWebsites
        self.selectedWebsites = []
        // TODO: remove Try!
        try! self.controller.update(selected, .init(isArchived: true)).get()
    }
    func unarchive() {
        let selected = self.selectedWebsites
        self.selectedWebsites = []
        // TODO: remove Try!
        try! self.controller.update(selected, .init(isArchived: false)).get()
    }
    func toggleFilter() {
        self.query.isArchived.toggle()
    }
    func open(in open: OpenURLAction) {
        self.selectedWebsites
            .compactMap { $0.value.preferredURL }
            .forEach { open($0) }
    }
    func open(in wm: WindowPresentation) {
        let _urls = self.selectedWebsites.compactMap { $0.value.preferredURL }
        guard _urls.isEmpty == false else { fatalError("Maybe present an error?") }
        guard wm.features.contains(.multipleWindows) else { fatalError("Maybe present an error?") }
        let urls = wm.features.contains(.bulkActivation)
            ? Set(_urls)
            : Set([_urls.first!])
        wm.show(urls) {
            // TODO: Do something with this error
            print($0)
        }
    }
}
