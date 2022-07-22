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
public struct ToolbarQuery: DynamicProperty {
    
    public struct Value {
        public var isEmpty:       Bool = true
        public var canArchiveYes: Bool = false
        public var canArchiveNo:  Bool = false
        public var openURL: SingleMulti<URL> = .none
        public var openWebsite: SingleMulti<Website.Selection.Element> = .none
    }
    
    @Controller private var controller
    
    @State public var canArchiveYes: Bool = false
    @State public var canArchiveNo:  Bool = false
    @State public var openURL: SingleMulti<URL> = .none
    @State public var openWebsite: SingleMulti<Website.Selection.Element> = .none
    
    @State private var selection: Website.Selection = []
    @Environment(\.codableErrorResponder) private var errorResponder
    
    public init() {}
    
    public var wrappedValue: Value {
        .init(isEmpty:       self.selection.isEmpty,
              canArchiveYes: self.canArchiveYes,
              canArchiveNo:  self.canArchiveNo,
              openURL:       self.openURL,
              openWebsite:   self.openWebsite)
    }

    public func setArchive(_ newValue: Bool) {
        let result = type(of: self).setArchive(newValue,
                                               self.selection,
                                               self.controller)
        guard let error = result.error else { return }
        NSLog(String(describing: error))
        self.errorResponder(.init(error as NSError))
    }
    
    public func setSelection(_ newValue: Website.Selection) {
        self.selection = newValue
        self.recalculate()
    }
    
    private func recalculate() {
        let controller = self.controller
        let selection = self.selection
        self.canArchiveYes = type(of: self).canArchiveYes(selection, controller)
        self.canArchiveNo  = type(of: self).canArchiveNo(selection, controller)
        self.openURL       = type(of: self).openURL(selection, controller)
        self.openWebsite   = type(of: self).openWebsite(selection, controller)
    }
}

extension ToolbarQuery {
    // Workaround so this can be used from Menu
    public static func canArchiveYes(_ selection: Website.Selection, _ controller: ControllerProtocol) -> Bool {
        return (controller as! CD_Controller).canArchiveYes(selection)
    }
    public static func canArchiveNo(_ selection: Website.Selection, _ controller: ControllerProtocol) -> Bool {
        return (controller as! CD_Controller).canArchiveNo(selection)
    }
    public static func openURL(_ selection: Website.Selection, _ controller: ControllerProtocol) -> SingleMulti<URL> {
        return (controller as! CD_Controller).openURL(selection)
    }
    public static func openWebsite(_ selection: Website.Selection, _ controller: ControllerProtocol) -> SingleMulti<Website.Selection.Element> {
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
    public static func canEditTags(_ selection: Tag.Selection) -> Bool {
        guard selection.isEmpty == false else { return false }
        return selection.contains { $0.isSystem } == false
    }
}
