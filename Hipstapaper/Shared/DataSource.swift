//
//  Created by Jeffrey Bergier on 2021/02/04.
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

import Datum

protocol DataSource: ObservableObject {
    associatedtype Observer: Datum.ListObserver where Observer.Collection.Element: Hashable & Identifiable
    
    var controller: Controller { get }
    /// Should be @Published
    var observer: Observer? { get }
    /// Computed property that `{ observer?.data ?? .empty }`
    var data: Observer.Collection { get }
    
    /// Causes the observer to be created and start observing
    @discardableResult
    func activate() -> Result<Void, Datum.Error>
    /// Causes the observer to be deallocated and no longer be observed
    func deactivate()
}
