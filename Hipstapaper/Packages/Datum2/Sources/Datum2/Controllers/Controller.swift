//
//  Created by Jeffrey Bergier on 2022/03/12.
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

// Read more about FetchedResults type
// https://developer.apple.com/documentation/swiftui/fetchedresults
// https://www.raywenderlich.com/9335365-core-data-with-swiftui-tutorial-getting-started

import Foundation
import CoreData
import Umbrella
import SwiftUI

public func ControllerNew() -> Result<Controller, Error> {
    return CD_Controller.new()
}

public protocol Controller {

    static var storeDirectoryURL: URL { get }
    static var storeExists: Bool { get }
    
    var ENVIRONMENTONLY_managedObjectContext: NSManagedObjectContext { get }
    
    // MARK: Sync
    var syncProgress: AnyContinousProgress { get }

    // MARK: Websites CRUD
    func createWebsite(_ website: Website?) -> Result<Website.Ident, Error>
    func delete(_: Set<Website.Ident>) -> Result<Void, Error>

    // MARK: Tags CRUD
    func createTag() -> Result<Tag.Ident, Error>
    func delete(_: Set<Tag.Ident>) -> Result<Void, Error>
    
    // MARK: Custom Functions
//    func add(tag: AnyElementObserver<AnyTag>, to websites: Set<AnyElementObserver<AnyWebsite>>) -> Result<Void, Error>
//    func remove(tag: AnyElementObserver<AnyTag>, from websites: Set<AnyElementObserver<AnyWebsite>>) -> Result<Void, Error>
//    func tagStatus(for websites: Set<AnyElementObserver<AnyWebsite>>) -> Result<AnyRandomAccessCollection<(AnyElementObserver<AnyTag>, ToggleState)>, Error>
}

@propertyWrapper
public struct ControllerProperty: DynamicProperty {
    
    @EnvironmentObject private var controller: BlackBox<Controller?>
    
    public init() { }
    
    public var wrappedValue: Controller {
        self.controller.value!
    }
    
}
