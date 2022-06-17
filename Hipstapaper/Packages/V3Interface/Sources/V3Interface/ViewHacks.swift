//
//  Created by Jeffrey Bergier on 2022/06/17.
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

extension Set: Identifiable where Element: Identifiable, Element.ID == String {
    public var id: Self.Element.ID { self.first?.id ?? UUID().uuidString }
}

extension Array: Identifiable where Element: Identifiable, Element.ID == String {
    public var id: Self.Element.ID { self.first?.id ?? UUID().uuidString }
}

extension View {
    public func popover<T: Identifiable, V: View>(items: Binding<Set<T>>, @ViewBuilder content: @escaping (Set<T>) -> V) -> some View where T.ID == String {
        let newBinding: Binding<Set<T>?> = Binding {
            items.wrappedValue.isEmpty ? nil : items.wrappedValue
        } set: {
            items.wrappedValue = $0 ?? []
        }
        return self.popover(item: newBinding, content: content)
    }
    
    public func popover<T: Identifiable, V: View>(items: Binding<Array<T>>, @ViewBuilder content: @escaping (Array<T>) -> V) -> some View where T.ID == String {
        let newBinding: Binding<Array<T>?> = Binding {
            items.wrappedValue.isEmpty ? nil : items.wrappedValue
        } set: {
            items.wrappedValue = $0 ?? []
        }
        return self.popover(item: newBinding, content: content)
    }
}
