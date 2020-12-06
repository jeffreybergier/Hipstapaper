//
//  Created by Jeffrey Bergier on 2020/12/06.
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
import Foundation
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif

public struct Thumbnail: View {
    
    public typealias Input = Data
    
    public let input: Input?
    
    public var body: Image? {
        guard let data = self.input else { return nil }
        #if canImport(AppKit)
        guard let image = NSImage(data: data) else { return nil }
        return Image(nsImage: image).resizable()
        #elseif canImport(UIKit)
        guard let image = UIImage(data: data) else { return nil }
        return Image(uiImage: image).resizable()
        #else
        fatalError()
        #endif
    }
    
    public init(_ input: Input?) {
        self.input = input
    }
}
