//
//  Created by Jeffrey Bergier on 2020/12/29.
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
import Combine

class TagDataSource: DataSource {
    
    @Published var observer: AnyListObserver<AnyList<AnyElementObserver<AnyTag>>>?
    var data: AnyList<AnyElementObserver<AnyTag>> { self.observer?.data ?? .empty }
    let controller: Controller
    
    init(controller: Controller) {
        self.controller = controller
    }
    
    func activate() -> Result<Void, Datum.Error> {
        log.verbose()
        guard self.observer == nil else { return .success(()) }
        let result = controller.readTags()
        self.observer = result.value
        return result.map { _ in () }
    }
    
    func deactivate() {
        log.verbose()
        self.objectWillChange.send()
        self.observer = nil
    }
    
    deinit {
        // TODO: Remove later
        log.emergency()
    }
}
