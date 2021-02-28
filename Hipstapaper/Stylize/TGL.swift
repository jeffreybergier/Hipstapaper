//
//  Created by Jeffrey Bergier on 2020/12/14.
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

extension STZ {
    public struct TGL: ViewModifier {
        public typealias Action = (Bool) -> Void
        private struct ViewModel {
            let action: Action
            var value: Bool {
                didSet {
                    self.action(self.value)
                }
            }
        }
        @State private var viewModel: ViewModel
        public func body(content: Content) -> some View {
            Toggle(isOn: self.$viewModel.value, label: { content })
        }
        public init(initialValue: Bool, action: @escaping Action) {
            _viewModel = .init(initialValue: .init(action: action,
                                                   value: initialValue))
        }
    }
}
