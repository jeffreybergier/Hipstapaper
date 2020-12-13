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

public func UIControllerNew(controller: Controller) -> AnyUIController {
    return AnyUIController(DefaultUIController(controller: controller))
}

/// No magic happens here, It is your responsibility to merge the `objectWillChange` signals
public protocol UIController: ObservableObject {
    var indexFixed: [AnyTag] { get }
    var indexTags: Result<AnyCollection<AnyElement<AnyTag>>, Error> { get }
    var detailWebsites: Result<AnyCollection<AnyElement<AnyWebsite>>, Error> { get }
    var controller: Controller { get }

    /// These properties are separate because SwiftUI is not smart enough to update a complex property
    var detailQuery: Query { get set }
    var selectedTag: AnyTag? { get set }
    var selectedWebsites: Set<AnyWebsite> { get set }
}
