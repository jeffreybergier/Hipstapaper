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

class WebsiteController: ObservableObject {
    
    private let selectedTag: AnyElement<AnyTag>
    
    let controller: Controller
    var all: AnyList<AnyElement<AnyWebsite>> = .empty
    @Published var query: Query = .init() {
        didSet {
            self.update()
        }
    }
    
    private var token: AnyCancellable?
    
    init(controller: Controller, selectedTag: AnyElement<AnyTag>) {
        self.selectedTag = selectedTag
        self.controller = controller
        self.update()
    }
    
    private func update() {
        self.token?.cancel()
        self.token = nil
        let result = controller.readWebsites(query: self.query)
        switch result {
        case .failure(let error):
            // TODO: Do something with this error
            self.all = .empty
            break
        case .success(let sites):
            self.all = sites
            self.token = sites.objectWillChange.sink { [unowned self] _ in
                self.objectWillChange.send()
            }
        }
    }
}
