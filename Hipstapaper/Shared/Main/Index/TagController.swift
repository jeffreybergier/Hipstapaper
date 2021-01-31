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

class TagController: ObservableObject {
    
    @Published var selection: AnyElement<AnyTag>?
    @Published private var tags: AnyObserver<AnyList<AnyElement<AnyTag>>>?
    
    let controller: Controller
    let `static` = Query.Archived.anyTag_allCases
    var all: AnyList<AnyElement<AnyTag>> {
        get {
            if let tags = self.tags { return tags.data }
            self.update()
            return self.tags?.data ?? .empty
        }
    }
        
    init(controller: Controller) {
        self.controller = controller
    }
    
    private func update() {
        let result = controller.readTags()
        self.objectWillChange.send()
        switch result {
        case .success(let tags):
            self.tags = tags
        case .failure(let error):
            // TODO: Do something with this error
            self.tags = nil
        }
    }
}

// MARK: Toolbar Helpers
extension TagController {
    func canDelete() -> Bool {
        guard let tag = self.selection else { return false }
        return (tag.value.wrappedValue as? Query.Archived) == nil
    }
    func delete(_ errorQ: ErrorQ) {
        guard let tag = self.selection else { return }
        let r = errorQ.append(self.controller.delete(tag))
        log.error(r.error)
    }
}
