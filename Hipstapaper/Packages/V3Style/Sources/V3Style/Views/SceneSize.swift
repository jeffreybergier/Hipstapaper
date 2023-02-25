//
//  Created by Jeffrey Bergier on 2023/02/25.
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

// TODO: Make these internal
// for some reason there is a build error
// when building for release when they are internal

public struct SceneSize: ViewModifier {
    
    public enum Size {
        case small
    }
    
    private let size: Size
    
    public init(size: Size) {
        self.size = size
    }
    
    public func body(content: Content) -> some View {
        content
            .frame(minWidth: self.width, minHeight: self.height)
    }
    
    private var width: CGFloat {
        switch self.size {
        case .small: return .sceneSizeWidthSmall
        }
    }
    
    private var height: CGFloat {
        switch self.size {
        case .small: return .sceneSizeHeightSmall
        }
    }
}
