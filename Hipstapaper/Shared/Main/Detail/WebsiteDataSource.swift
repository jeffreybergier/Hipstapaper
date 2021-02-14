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

class WebsiteDataSource: DataSource {
    
    private weak var errorQ: ErrorQ?
    
    @Published var query: Query { didSet { self.activate(self.errorQ) } }
    @Published var observer: AnyListObserver<AnyList<AnyElementObserver<AnyWebsite>>>?
    var data: AnyList<AnyElementObserver<AnyWebsite>> { self.observer?.data ?? .empty }
    
    let controller: Controller
    
    init(controller: Controller,
         selectedTag: AnyElementObserver<AnyTag> = Query.Filter.anyTag_allCases[0])
    {
        self.query = Query(specialTag: selectedTag)
        self.controller = controller
    }
    
    func activate(_ errorQ: ErrorQ?) {
        self.errorQ = errorQ
        log.verbose(self.query.tag?.value.name ?? self.query.filter)
        let result = controller.readWebsites(query: self.query)
        self.observer = result.value
        errorQ?.append(result)
    }
    
    func deactivate() {
        log.verbose(self.query.tag?.value.name ?? self.query.filter)
        self.observer = nil
    }
    
    #if DEBUG
    deinit {
        log.verbose()
    }
    #endif
}
