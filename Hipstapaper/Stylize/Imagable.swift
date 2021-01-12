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
    public static var image: Image {
        return SwiftUI.Image(systemName: self.name)
    }
    public static var thumbnail: some View {
        return self.image.modifier(__Thumbnail())
    }
}

fileprivate struct __Thumbnail: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    func body(content: Content) -> some View {
        ZStack {
            self.colorScheme.isNormal
                ? Color.thumbnailPlaceholder
                : Color.thumbnailPlaceholder_Dark
            self.colorScheme.isNormal
                ? content.foregroundColor(.textTitle)
                : content.foregroundColor(.textTitle_Dark)
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
    }
}
