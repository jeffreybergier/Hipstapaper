//
//  Created by Jeffrey Bergier on 2021/02/05.
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

import SwiftUI
import Umbrella
import Datum
import Stylize

typealias WH = WebsiteHelper

enum WebsiteHelper {
    
    typealias Selection = Set<AnyElementObserver<AnyWebsite>>
    
    static func canShare(_ selection: Selection) -> Bool {
        return selection.first(where: { $0.value.preferredURL != nil }) != nil
    }
    static func canTag(_ selection: Selection) -> Bool {
        return selection.isEmpty == false
    }
    static func canArchive(_ selection: Selection) -> Bool {
        return selection.first(where: { $0.value.isArchived == false }) != nil
    }
    static func canUnarchive(_ selection: Selection) -> Bool {
        return selection.first(where: { $0.value.isArchived == true }) != nil
    }
    static func canDelete(_ selection: Selection) -> Bool {
        return selection.isEmpty == false
    }
    static func canOpen(_ selection: Selection, in wm: WindowPresentation) -> Bool {
        if wm.features.contains(.bulkActivation) {
            return selection.first(where: { $0.value.preferredURL != nil }) != nil
        } else {
            return selection.compactMap { $0.value.preferredURL != nil }.count == 1
        }
    }
    
    static func archive(_ selection: Selection, _ controller: Controller, _ errorQ: ErrorQueue) {
        let result = controller.update(selection, .init(isArchived: true))
        result.error.map {
            errorQ.queue.append($0)
            log.error($0)
        }
    }
    
    static func unarchive(_ selection: Selection, _ controller: Controller, _ errorQ: ErrorQueue) {
        let result = controller.update(selection, .init(isArchived: false))
        result.error.map {
            errorQ.queue.append($0)
            log.error($0)
        }
    }
    
    static func delete(_ selection: Selection, _ controller: Controller, _ errorQ: ErrorQueue) {
        let result = controller.delete(selection)
        result.error.map {
            errorQ.queue.append($0)
            log.error($0)
        }
    }
    
    static func open(_ selection: Selection, in open: OpenURLAction) {
        selection
            .compactMap { $0.value.preferredURL }
            .forEach { open($0) }
    }
    
    @discardableResult
    /// Item returned if device not capable of window presentation
    static func open(_ selection: Selection, in wm: WindowPresentation, _ errorQ: ErrorQueue) -> AnyElementObserver<AnyWebsite>? {
        guard selection.isEmpty == false else { return nil }
        let urls = selection.compactMap { $0.value.preferredURL }
        
        guard urls.isEmpty == false else { fatalError("Maybe present an error?") }
        guard wm.features.contains([.multipleWindows, .bulkActivation])
            else { return selection.first! }
        
        wm.show(Set(urls))
        return nil
    }
    
    @ViewBuilder static func filterToolbarItem(_ query: Query,
                                               action: @escaping () -> Void) -> some View
    {
        if query.filter.boolValue {
            // disable this when there is no tag selected
            STZ.TB.FilterActive.toolbar(isEnabled: query.tag != nil, action: action)
        } else {
            // disable this when there is no tag selected
            STZ.TB.FilterInactive.toolbar(isEnabled: query.tag != nil, action: action)
        }
    }
    
    @ViewBuilder static func searchToolbarItem(_ query: Query,
                                               action: @escaping () -> Void) -> some View
    {
        if query.isSearchActive {
            STZ.TB.SearchInactive.toolbar(action: action)
        } else {
            STZ.TB.SearchActive.toolbar(action: action)
        }
    }
}
