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
    let controller: Controller
    let `static` = Query.Archived.anyTag_allCases
    var all: AnyList<AnyElement<AnyTag>> {
        get {
            if let all = _all { return all }
            self.update()
            return _all ?? .empty
        }
    }
    
    private var _all: AnyList<AnyElement<AnyTag>>?
    private var token: AnyCancellable?
    
    init(controller: Controller) {
        self.controller = controller
    }
    
    private func update() {
        self.token?.cancel()
        self.token = nil
        let result = controller.readTags()
        switch result {
        case .failure(let error):
            // TODO: Do something with this error
            _all = nil
        case .success(let tags):
            _all = tags
            self.objectWillChange.send()
            self.token = tags.objectWillChange.sink() { [unowned self] _ in
                self.objectWillChange.send()
            }
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
        errorQ.append(self.controller.delete(tag))
    }
}
