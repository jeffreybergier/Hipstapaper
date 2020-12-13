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

/// No magic happens here, It is your responsibility to merge the `objectWillChange` signals
public class AnyUIController: UIController {
    
    public let objectWillChange: ObservableObjectPublisher
    
    public var indexFixed: [AnyTag] { getIndexFixed() }
    public var indexTags: Result<AnyCollection<AnyElement<AnyTag>>, Error> { getController().readTags() }
    public var detailWebsites: Result<AnyCollection<AnyElement<AnyWebsite>>, Error> { getController().readWebsites(query: self.detailQuery) }
    public var controller: Controller { getController() }
    
    public var detailQuery: Query {
        get { getDetailQuery() }
        set { setDetailQuery(newValue) }
    }
    public var selectedTag: AnyTag? {
        get { self.getSelectedTag() }
        set { self.setSelectedTag(newValue) }
    }
    public var selectedWebsites: Set<AnyWebsite> {
        get { self.getSelectedWebsite() }
        set { self.setSelectedWebsite(newValue) }
    }
    
    private var getController:      () -> Controller
    private var getIndexFixed:      () -> [AnyTag]
    private var getDetailQuery:     () -> Query
    private var setDetailQuery:     (Query) -> Void
    private var getSelectedTag:     () -> AnyTag?
    private var setSelectedTag:     (AnyTag?) -> Void
    private var getSelectedWebsite: () -> Set<AnyWebsite>
    private var setSelectedWebsite: (Set<AnyWebsite>) -> Void
    
    public init<T: UIController>(_ controller: T) where T.ObjectWillChangePublisher == ObservableObjectPublisher {
        self.getController      = { controller.controller }
        self.getIndexFixed      = { controller.indexFixed }
        self.getDetailQuery     = { controller.detailQuery }
        self.setDetailQuery     = { controller.detailQuery = $0 }
        self.getSelectedTag     = { controller.selectedTag }
        self.setSelectedTag     = { controller.selectedTag = $0 }
        self.getSelectedWebsite = { controller.selectedWebsites }
        self.setSelectedWebsite = { controller.selectedWebsites = $0 }
        self.objectWillChange   = controller.objectWillChange
    }
}
