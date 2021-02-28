//
//  Created by Jeffrey Bergier on 2020/12/28.
//
//  MIT License
//
//  Copyright (c) 2021 jeffreybergier
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Combine
import Umbrella
import Datum

class WebsiteDataSource: DataSource {
    
    private weak var errorQ: ErrorQueue?
    
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
    
    func activate(_ errorQ: ErrorQueue?) {
        self.errorQ = errorQ
        log.verbose(self.query.tag?.value.name ?? self.query.filter)
        let result = controller.readWebsites(query: self.query)
        self.observer = result.value
        result.error.map {
            errorQ?.queue.append($0)
            log.error($0)
        }
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
