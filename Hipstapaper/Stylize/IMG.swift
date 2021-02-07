//
//  Created by Jeffrey Bergier on 2021/01/12.
//
//  Copyright © 2020 Saturday Apps.
//
//  This file is part of Hipstapaper.
//
//  Hipstapaper is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Hipstapaper is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Hipstapaper.  If not, see <http://www.gnu.org/licenses/>.
//

import SwiftUI

public protocol Imagable {
    static var name: String { get }
}

extension Imagable {
    fileprivate static var image: Image {
        return Image(systemName: self.name)
    }
    
    /// Returns a thumbnail image of icon
    /// If data can be converted to image, it returns that instead
    
    // TODO: Make this take a Result<Data, LocalizedError>
    @ViewBuilder public static func thumbnail(_ data: Data? = nil) -> some View {
        if let image = data?.imageValue {
            image
                .modifier(STZ.CRN.small())
                .aspectRatio(1, contentMode: .fit)
        } else {
            self.image
                .modifier(Thumbnail())
                .modifier(STZ.CRN.small())
                .aspectRatio(1, contentMode: .fit)
        }
    }
}

extension STZ {
    public enum IMG {
        public enum Web: Imagable {
            public static let name: String = "globe"
        }
        public enum WebError: Imagable {
            public static let name: String = "exclamationmark.icloud"
        }
        public enum Bug: Imagable {
            public static let name: String = "ladybug"
        }
        public enum Placeholder: Imagable {
            public static let name: String = "photo"
        }
    }
}


fileprivate struct Thumbnail: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    func body(content: Content) -> some View {
        ZStack {
            STZ.CLR.Thumbnail.Background.view()
            content
                .modifier(STZ.CLR.Thumbnail.Icon.foreground())
        }
    }
}

#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension Data {
    fileprivate var imageValue: Image? {
        #if os(macOS)
        guard let image = NSImage(data: self) else { return nil }
        return Image(nsImage: image).resizable()
        #else
        guard let image = UIImage(data: self) else { return nil }
        return Image(uiImage: image).resizable()
        #endif
    }
}
