//
//  Created by Jeffrey Bergier on 2020/11/24.
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

import CoreData
import SwiftUI

// Read more about FetchedResults type
// https://developer.apple.com/documentation/swiftui/fetchedresults
// https://www.raywenderlich.com/9335365-core-data-with-swiftui-tutorial-getting-started

public protocol Controller {

    func create(title: String?,
                originalURL: URL?,
                resolvedURL: URL?,
                thumbnailData: Data?) -> Result<Void, Error>
    func readWebsites() -> FetchedResults<Website>
    func readTags() -> FetchedResults<Tag>

}
