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

extension AnyUIController {
    public class func newDefault(controller: Controller) -> AnyUIController {
        return AnyUIController(DefaultUIController(controller: controller))
    }
}

internal class DefaultUIController: UIController {
    
    private(set) lazy var tags: Result<AnyCollection<AnyElement<AnyTag>>, Error> = {
        defer { self.mergeStreams() }
        return self.controller.readTags()
    }()

    private(set) lazy var websites: Result<AnyCollection<AnyElement<AnyWebsite>>, Error> = {
        defer { self.mergeStreams() }
        return self.controller.readWebsites(query: self.currentQuery)
    }()

    internal var selectedWebsite: AnyWebsite? = nil
    internal var selectedTag: AnyTag? = nil {
        didSet {
            self.currentQuery.search = nil
            // TODO: Detect All/Unarchived
            self.currentQuery.tag = self.selectedTag
        }
    }

    private(set) var currentQuery: Query = .init() {
        didSet {
            self.websites = self.controller.readWebsites(query: self.currentQuery)
            self.mergeStreams()
        }
    }

    private let controller: Controller
    private var observation: AnyCancellable?
    
    internal init(controller: Controller) {
        self.controller = controller
    }

    private func mergeStreams() {
        self.observation?.cancel()
        self.observation = nil
        let streams = [
            self.tags.value?.objectWillChange,
            self.websites.value?.objectWillChange
        ].compactMap({ $0 })
        self.observation = Publishers.MergeMany(streams).sink() { [unowned self] in
            self.objectWillChange.send()
        }
        self.objectWillChange.send()
    }
}
