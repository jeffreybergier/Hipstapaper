//
//  Created by Jeffrey Bergier on 2022/07/30.
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

public struct PopoverSize: ViewModifier {
    
    public enum Size {
        case small, medium, large
    }
    
    private let size: Size
    
    public init(size: Size) {
        self.size = size
    }
    
    public func body(content: Content) -> some View {
        content
            .frame(idealWidth: self.width, idealHeight: self.height)
            .presentationDetents(self.detents)
    }
    
    private var width: CGFloat {
        switch self.size {
        case .small: return .popoverSizeWidthSmall
        case .medium: return .popoverSizeWidthMedium
        case .large: return .popoverSizeWidthLarge
        }
    }
    
    private var height: CGFloat {
        switch self.size {
        case .small: return .popoverSizeHeightSmall
        case .medium: return .popoverSizeHeightMedium
        case .large: return .popoverSizeHeightLarge
        }
    }
    
    private var detents: Set<PresentationDetent> {
        switch self.size {
        case .small: return [.medium]
        case .medium: return [.medium, .large]
        case .large: return [.large]
        }
    }
}

public struct SidebarListTitleText: ViewModifier {
    @Environment(\.dynamicTypeSize) private var typeSize
    public func body(content: Content) -> some View {
        content
            .lineLimit(self.typeSize.isAccessibilitySize ? 2 : 1, reservesSpace: true)
            .font(.normal)
    }
}

public struct DetailListTitleText: ViewModifier {
    @Environment(\.dynamicTypeSize) private var typeSize
    public func body(content: Content) -> some View {
        content
            .lineLimit(self.typeSize.isAccessibilitySize ? 3 : 2, reservesSpace: true)
            .font(.normal)
    }
}

public struct DetailListURLText: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .lineLimit(1, reservesSpace: true)
            .font(.small)
    }
}


public struct DetailListDateText: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .lineLimit(1, reservesSpace: true)
            .font(.small)
    }
}

public struct DetailTableTitleText: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .lineLimit(2, reservesSpace: true)
            .font(.prominent)
    }
}

public struct DetailTableURLText: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .lineLimit(2, reservesSpace: true)
            .font(.normal)
    }
}

public struct DetailTableDateText: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .lineLimit(2, reservesSpace: true)
            .font(.normal)
    }
}
