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
public struct WebsiteSearchListQuery: DynamicProperty {
    
    @State public var search: Website.Selection = []
    
    public var canArchiveYes: Bool {
        self.wrappedValue.contains(where: { $0.isArchived == false })
    }
    public var canArchiveNo: Bool {
        self.wrappedValue.contains(where: { $0.isArchived == true })
    }
    public var selectionValue: Website.Selection {
        Set(self.wrappedValue.map { $0.id })
    }
    public func setArchive(_ newValue: Bool) {
        self.projectedValue.forEach { $0.wrappedValue.isArchived = newValue }
    }
    public var wrappedValue: some RandomAccessCollection<Website> {
        return data.value.filter { self.search.contains($0.id) }
    }
    public var projectedValue: some RandomAccessCollection<Binding<Website>> {
        return data.projectedValue
            .filter { self.search.contains($0.wrappedValue.id) }
    }
    public init() {}
    
    // TODO: Hook up core data
    @ObservedObject private var data = siteEnvironment
    
}
