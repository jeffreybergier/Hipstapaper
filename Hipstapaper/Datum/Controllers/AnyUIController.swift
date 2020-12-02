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
    
    public var fixed: [AnyTag] { getFixed() }
    public var tags: Result<AnyCollection<AnyElement<AnyTag>>, Error> { getTags() }
    public var websites: Result<AnyCollection<AnyElement<AnyWebsite>>, Error> { getWebsites() }
    public var currentQuery: Query { getQuery() }
    
    public var selectedTag: AnyTag? {
        get { self.getSelectedTag() }
        set { self.setSelectedTag(newValue) }
    }
    public var selectedWebsite: AnyWebsite? {
        get { self.getSelectedWebsite() }
        set { self.setSelectedWebsite(newValue) }
    }
    
    private var getFixed:           () -> [AnyTag]
    private var getTags:            () -> Result<AnyCollection<AnyElement<AnyTag>>, Error>
    private var getWebsites:        () -> Result<AnyCollection<AnyElement<AnyWebsite>>, Error>
    private var getQuery:           () -> Query
    private var getSelectedTag:     () -> AnyTag?
    private var setSelectedTag:     (AnyTag?) -> Void
    private var getSelectedWebsite: () -> AnyWebsite?
    private var setSelectedWebsite: (AnyWebsite?) -> Void

    
    public init<T: UIController>(_ controller: T) where T.ObjectWillChangePublisher == ObservableObjectPublisher {
        self.getFixed           = { controller.fixed }
        self.getTags            = { controller.tags }
        self.getWebsites        = { controller.websites }
        self.getQuery           = { controller.currentQuery }
        self.getSelectedTag     = { controller.selectedTag }
        self.setSelectedTag     = { controller.selectedTag = $0 }
        self.getSelectedWebsite = { controller.selectedWebsite }
        self.setSelectedWebsite = { controller.selectedWebsite = $0 }
        self.objectWillChange   = controller.objectWillChange
    }
}
