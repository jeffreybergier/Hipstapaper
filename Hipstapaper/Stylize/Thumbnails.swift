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

public enum Thumbnail {
    
    public struct Image: View {
        
        @Environment(\.colorScheme) var colorScheme
        public let input: Data?
        
        public var body: some View {
            let topView = self.topView() ?? SwiftUI.Image(systemName: "photo")
            return ZStack {
                self.colorScheme.isNormal
                    ? Color.thumbnailPlaceholder
                    : Color.thumbnailPlaceholder_Dark
                self.colorScheme.isNormal
                    ? topView.foregroundColor(.textTitle)
                    : topView.foregroundColor(.textTitle_Dark)
            }
        }
        
        private func topView() -> SwiftUI.Image? {
            #if canImport(AppKit)
            guard
                let data = self.input,
                let image = NSImage(data: data)
            else { return nil }
            return SwiftUI.Image(nsImage: image).resizable()
            #elseif canImport(UIKit)
            guard
                let data = self.input,
                let image = UIImage(data: data)
            else { return nil }
            return SwiftUI.Image(uiImage: image).resizable()
            #else
            fatalError()
            #endif
        }
        
        public init(_ input: Data?) {
            self.input = input
        }
    }
    
    /// Displays SF Symbol above a placeholder color
    public struct SystemName: View {
        
        @Environment(\.colorScheme) var colorScheme
        let systemName: String
        
        public var body: some View {
            ZStack {
                self.colorScheme.isNormal
                    ? Color.thumbnailPlaceholder
                    : Color.thumbnailPlaceholder_Dark
                SwiftUI.Image(systemName: self.systemName)
            }
        }
        
        /// Does not check if your string is a valid SF Symbols name
        public init(_ systemName: String) {
            self.systemName = systemName
        }
        
    }
    
}
