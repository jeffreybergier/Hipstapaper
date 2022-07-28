//
//  Created by Jeffrey Bergier on 2021/02/05.
//
//  MIT License
//
//  Copyright (c) 2021 Jeffrey Bergier
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
import Localize

typealias WH = WebsiteHelper

enum WebsiteHelper {
    
    typealias Selection = Set<FAST_Website>
    
    static func canShare(_ selection: Selection) -> Bool {
        return selection.first(where: { $0.preferredURL != nil }) != nil
    }
    static func canTag(_ selection: Selection) -> Bool {
        return selection.isEmpty == false
    }
    static func canArchive(_ selection: Selection) -> Bool {
        return selection.first(where: { $0.isArchived == false }) != nil
    }
    static func canUnarchive(_ selection: Selection) -> Bool {
        return selection.first(where: { $0.isArchived == true }) != nil
    }
    static func canDelete(_ selection: Selection) -> Bool {
        return selection.isEmpty == false
    }
    static func canEdit(_ selection: Selection) -> Bool {
        return selection.isEmpty == false
    }
    static func canOpen(_ selection: Selection, in wm: WindowPresentation) -> Bool {
        if wm.features.contains(.bulkActivation) {
            return selection.first(where: { $0.preferredURL != nil }) != nil
        } else {
            return selection.compactMap { $0.preferredURL != nil }.count == 1
        }
    }
    
    static func archive(_ selection: Selection, _ controller: Controller, _ errorQ: ErrorQueue.Environment) {
        let result = controller.setArchive(true, on: Set(selection.map { $0.uuid }))
        result.error.map {
            NSLog(String(describing: $0))
            errorQ.value.append($0)
        }
    }
    
    static func unarchive(_ selection: Selection, _ controller: Controller, _ errorQ: ErrorQueue.Environment) {
        let result = controller.setArchive(false, on: Set(selection.map { $0.uuid }))
        result.error.map {
            NSLog(String(describing: $0))
            errorQ.value.append($0)
        }
    }
    
    static func delete(_ selection: Selection, _ controller: Controller, _ errorQ: ErrorQueue.Environment) {
        let result = controller.delete(Set(selection.map { $0.uuid }))
        result.error.map {
            NSLog(String(describing: $0))
            errorQ.value.append($0)
        }
    }
    
    static func open(_ selection: Selection, in open: OpenURLAction) {
        selection
            .compactMap { $0.preferredURL }
            .forEach { open($0) }
    }
    
    @discardableResult
    /// Item returned if device not capable of window presentation
    static func open(_ selection: Selection,
                     in wm: WindowPresentation,
                     controller: Controller) -> Website?
    {
        guard selection.isEmpty == false else { return nil }
        let websites = Set(selection.map { $0.websiteValue })
        
        guard websites.isEmpty == false else { fatalError("Maybe present an error?") }
        guard wm.features.contains([.multipleWindows, .bulkActivation])
            else { return selection.first?.websiteValue }
        
        wm.show(websites, controller: controller)
        return nil
    }
    
    @ViewBuilder static func filterToolbarItem(query: Query,
                                               selection: TagListSelection?,
                                               bundle: LocalizeBundle,
                                               action: @escaping () -> Void)
                                               -> some View
    {
        switch selection ?? .default {
        case .notATag(let tag):
            switch tag {
            case .unread:
                STZ.TB.FilterActive.toolbar(isEnabled: false, bundle: bundle, action: action)
            case .all:
                STZ.TB.FilterInactive.toolbar(isEnabled: false, bundle: bundle, action: action)
            }
        case .tag(_):
            if query.isOnlyNotArchived == true {
                STZ.TB.FilterActive.toolbar(bundle: bundle, action: action)
            } else {
                STZ.TB.FilterInactive.toolbar(bundle: bundle, action: action)
            }
        }
    }
    
    @ViewBuilder static func searchToolbarItem(_ search: String,
                                               bundle: LocalizeBundle,
                                               action: @escaping () -> Void) -> some View
    {
        if search.trimmed == nil {
            STZ.TB.SearchInactive.toolbar(bundle: bundle, action: action)
        } else {
            STZ.TB.SearchActive.toolbar(bundle: bundle, action: action)
        }
    }
}
