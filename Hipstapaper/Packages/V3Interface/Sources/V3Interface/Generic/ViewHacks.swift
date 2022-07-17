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
import Umbrella

extension View {
    public func popover<C: Collection & ExpressibleByArrayLiteral, V: View>(
        items: Binding<C>,
        @ViewBuilder content: @escaping (C) -> V
    ) -> some View
    {
        return self.popover(isPresented: items.isPresented) {
            content(items.wrappedValue)
        }
    }
    
    public func sheet<C: Collection & ExpressibleByArrayLiteral, V: View>(
        items: Binding<C>,
        @ViewBuilder content: @escaping (C) -> V,
        onDismiss: (() -> Void)? = nil
    )
    -> some View
    {
        return self.sheet(isPresented: items.isPresented, onDismiss: onDismiss) {
            content(items.wrappedValue)
        }
    }
}

/*
// TODO: Use this one is sheet above causes double presentation issue
public func sheet2<T: Identifiable, V: View>(items: Binding<Set<T>>,
                                            @ViewBuilder content: @escaping (Set<T>) -> V,
                                            onDismiss: (() -> Void)? = nil)
                                            -> some View
{
    return self.sheet(isPresented: items.isPresented, onDismiss: onDismiss) {
        content(items.wrappedValue)
    }
}
*/
