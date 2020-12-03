//
//  Created by Jeffrey Bergier on 2020/12/01.
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

internal class DefaultUIController: UIController {
    
    private(set) lazy var indexFixed: [AnyTag] = Query.Archived.anyTag_allCases
    private(set) var indexTags: Result<AnyCollection<AnyElement<AnyTag>>, Error>
    private(set) var detailWebsites: Result<AnyCollection<AnyElement<AnyWebsite>>, Error>

    internal var selectedWebsite: AnyWebsite? = nil
    internal var selectedTag: AnyTag? = nil {
        didSet {
            var query = self.detailQuery
            defer { self.detailQuery = query }
            query.search = nil
            query.tag = nil
            if let isArchived = self.selectedTag?.wrappedValue as? Query.Archived {
                query.isArchived = isArchived
            } else {
                query.tag = self.selectedTag
            }
        }
    }

    private(set) var detailQuery: Query = .init() {
        didSet {
            self.detailWebsites = self.controller.readWebsites(query: self.detailQuery)
            self.mergeStreams()
        }
    }

    private let controller: Controller
    private var observation: AnyCancellable?
    
    internal init(controller: Controller) {
        self.controller = controller
        self.indexTags = self.controller.readTags()
        self.detailWebsites = self.controller.readWebsites(query: self.detailQuery)
        self.mergeStreams()
    }

    private func mergeStreams() {
        self.observation?.cancel()
        self.observation = nil
        let streams = [
            self.indexTags.value?.objectWillChange,
            self.detailWebsites.value?.objectWillChange
        ].compactMap({ $0 })
        self.observation = Publishers.MergeMany(streams).sink() { [unowned self] in
            self.objectWillChange.send()
        }
        self.objectWillChange.send()
    }
}
