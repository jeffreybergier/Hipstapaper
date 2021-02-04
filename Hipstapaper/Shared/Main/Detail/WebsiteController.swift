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
    
    @Published var selectedWebsites: Set<AnyElement<AnyWebsite>> = []
    @Published var query: Query { didSet { self.activate() } }
    @Published private var sites: AnyObserver<AnyList<AnyElement<AnyWebsite>>>?
    
    let controller: Controller
    var all: AnyList<AnyElement<AnyWebsite>> { sites?.data ?? .empty }
    
    init(controller: Controller, selectedTag: AnyElement<AnyTag> = Query.Archived.anyTag_allCases[0]) {
        self.query = Query(specialTag: selectedTag)
        self.controller = controller
    }
    
    func activate() {
        log.verbose()
        let result = controller.readWebsites(query: self.query)
        switch result {
        case .success(let sites):
            self.sites = sites
        case .failure(let error):
            // TODO: Do something with this error
            self.sites = nil
        }
    }
    
    func deactivate() {
        log.verbose()
        self.objectWillChange.send()
        self.sites = nil
    }
    
    deinit {
        log.verbose()
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
    func canDelete() -> Bool {
        return self.selectedWebsites.isEmpty == false
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
    
    func archive(_ errorQ: ErrorQ) {
        let selected = self.selectedWebsites
        self.selectedWebsites = []
        let r = errorQ.append(self.controller.update(selected, .init(isArchived: true)))
        log.error(r.error)
    }
    
    func unarchive(_ errorQ: ErrorQ) {
        let selected = self.selectedWebsites
        self.selectedWebsites = []
        let r = errorQ.append(self.controller.update(selected, .init(isArchived: false)))
        log.error(r.error)
    }
    
    func delete(_ errorQ: ErrorQ) {
        let selected = self.selectedWebsites
        self.selectedWebsites = []
        let r = errorQ.append(self.controller.delete(selected))
        log.error(r.error)
    }
    
    func toggleFilter() {
        self.query.isArchived.toggle()
    }
    
    func open(in open: OpenURLAction) {
        self.selectedWebsites
            .compactMap { $0.value.preferredURL }
            .forEach { open($0) }
    }
    
    @discardableResult
    func open(in wm: WindowPresentation) -> AnyElement<AnyWebsite>? {
        let sites = self.selectedWebsites
        let urls = sites.compactMap { $0.value.preferredURL }
        
        guard urls.isEmpty == false else { fatalError("Maybe present an error?") }
        guard wm.features.contains([.multipleWindows, .bulkActivation])
            else { return sites.first! }
        
        wm.show(Set(urls)) {
            // TODO: Do something with this error
            print($0)
        }
        return nil
    }
}

class WebsiteDataSource: DataSourceMultiSelectable {
    
    @Published var selection: Set<AnyElement<AnyWebsite>> = []
    @Published var query: Query
    @Published var observer: AnyObserver<AnyList<AnyElement<AnyWebsite>>>?
    var data: AnyList<AnyElement<AnyWebsite>> { self.observer?.data ?? .empty }
    
    let controller: Controller
    
    init(controller: Controller, selectedTag: AnyElement<AnyTag> = Query.Archived.anyTag_allCases[0]) {
        self.query = Query(specialTag: selectedTag)
        self.controller = controller
    }
    
    func activate() -> Result<Void, Datum.Error> {
        log.verbose()
        let result = controller.readWebsites(query: self.query)
        self.observer = result.value
        return result.map { _ in () }
    }
    
    func deactivate() {
        log.verbose()
        self.objectWillChange.send()
        self.observer = nil
    }
    
}
