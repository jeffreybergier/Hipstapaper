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

public struct ImageThumbnail: View {
        
    public let input: Data?
    
    public var body: some View {
        let topView = self.topView() ?? Image(systemName: "photo")
        return ZStack {
            Color.Placeholder()
            topView
        }
    }
    
    private func topView() -> Image? {
        #if canImport(AppKit)
        guard
            let data = self.input,
            let image = NSImage(data: data)
        else { return nil }
        return Image(nsImage: image).resizable()
        #elseif canImport(UIKit)
        guard
            let data = self.input,
            let image = UIImage(data: data)
        else { return nil }
        return Image(uiImage: image).resizable()
        #else
        fatalError()
        #endif
    }
    
    public init(_ input: Data?) {
        self.input = input
    }
}

/// Displays SF Symbol above a placeholder color
public struct SystemThumbnail: View {

    let systemName: String

    public var body: some View {
        ZStack {
            Color.Placeholder()
            Image(systemName: self.systemName)
        }
    }

    /// Does not check if your string is a valid SF Symbols name
    public init(systemName: String) {
        self.systemName = systemName
    }

}
