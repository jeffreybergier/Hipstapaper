//
//  Created by Jeffrey Bergier on 2022/06/25.
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
import V3Model

@propertyWrapper
public struct BulkActionsQuery: DynamicProperty {
    
    public struct Value: Hashable {
        public var websiteAdd: Bool = false
        public var tagAdd: Bool = false
        /// Contains items that can be deselected
        public var deselectAll: Website.Selection = []
        /// Contains items that need to be selected
        public var selectAll: Website.Selection = []
        public var openInApp: SingleMulti<Website.Selection.Element>? = nil
        public var openExternal: SingleMulti<URL>? = nil
        public var share: Website.Selection = []
        public var archiveYes: Website.Selection = []
        public var archiveNo: Website.Selection = []
        public var tagApply: Website.Selection = []
        public var websiteEdit: Website.Selection = []
        public var tagsEdit: Tag.Selection = []
        public var websiteDelete: Website.Selection = []
        public var tagDelete: Tag.Selection = []
        public var showErrors: Bool = false
        public init() {}
    }
    
    @Controller private var controller
    
    @State private var valueCache: Value = .init()
    
    @State private var allWebsites: Website.Selection = []
    @State private var websiteSelection: Website.Selection = []
    @State private var tagSelection: Tag.Selection = []
    @Environment(\.codableErrorResponder) private var errorResponder
    
    public init() {}
    
    public var wrappedValue: Value {
        get { self.valueCache }
        nonmutating set { self.valueCache = newValue }
    }
    
    public func setWebsite(selection newValue: Website.Selection) {
        self.websiteSelection = newValue
        self.recalculate()
    }
    
    public func setTag(selection newValue: Tag.Selection) {
        self.tagSelection = newValue
        self.recalculate()
    }
    
    public func setAll(selection newValue: Website.Selection) {
        self.allWebsites = newValue
        self.recalculate()
    }
    
    private func recalculate() {
        let controller = self.controller
        let allW       = self.allWebsites
        let selectionW = self.websiteSelection
        let selectionT = self.tagSelection
        
        // reset default state
        self.valueCache.websiteAdd = false
        self.valueCache.tagAdd = false
        
        // set things that are always true
        self.valueCache.share = selectionW
        self.valueCache.tagApply = selectionW
        self.valueCache.websiteEdit = selectionW
        self.valueCache.websiteDelete = selectionW
        self.valueCache.deselectAll = selectionW
        self.valueCache.selectAll = allW
        
        // set things with custom logic
        self.valueCache.openInApp = type(of: self).openWebsite(selectionW, controller)
        self.valueCache.openExternal = type(of: self).openURL(selectionW, controller)
        self.valueCache.archiveYes = type(of: self).canArchiveYes(selectionW, controller)
        self.valueCache.archiveNo = type(of: self).canArchiveNo(selectionW, controller)
        self.valueCache.tagDelete = type(of: self).editTags(selectionT)
        self.valueCache.tagsEdit = type(of: self).editTags(selectionT)
    }
}

extension BulkActionsQuery {
    // Workaround so this can be used from Menu
    public static func canArchiveYes(_ selection: Website.Selection, _ controller: ControllerProtocol) -> Website.Selection {
        return (controller as! CD_Controller).canArchiveYes(selection) ? selection : []
    }
    public static func canArchiveNo(_ selection: Website.Selection, _ controller: ControllerProtocol) -> Website.Selection {
        return (controller as! CD_Controller).canArchiveNo(selection) ? selection : []
    }
    public static func openURL(_ selection: Website.Selection, _ controller: ControllerProtocol) -> SingleMulti<URL>? {
        return (controller as! CD_Controller).openURL(selection)
    }
    public static func openWebsite(_ selection: Website.Selection, _ controller: ControllerProtocol) -> SingleMulti<Website.Selection.Element>? {
        return (controller as! CD_Controller).openURL(selection)
    }
    public static func setArchive(_ newValue: Bool,
                                  _ selection: Website.Selection,
                                  _ controller: ControllerProtocol)
                                  -> Result<Void, Error>
    {
        let controller = controller as! CD_Controller
        return controller.setArchive(newValue, on: selection)
    }
    public static func editTags(_ selection: Tag.Selection) -> Tag.Selection {
        return selection.filter { $0.isSystem == false }
    }
}
