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
    
    public typealias Input = Result<Data, Error>
    
    @Binding public var input: Input?
    
    public var body: Image {
        guard let input = self.input else {
            return Thumbnail.ErrorImage
        }
        switch input {
        case .success(let data):
            #if canImport(AppKit)
            guard let image = NSImage(data: data) else {
                return Thumbnail.ErrorImage
            }
            return Image(nsImage: image).resizable()
            #elseif canImport(UIKit)
            guard let image = UIImage(data: data) else {
                return Thumbnail.ErrorImage
            }
            return Image(uiImage: image).resizable()
            #else
            return Thumbnail.ErrorImage
            #endif
        case .failure:
            return Thumbnail.ErrorImage
        }
    }
    
    public init(_ input: Binding<Input?>) {
        _input = input
    }
    
    public static let ErrorImage = Image(systemName: "exclamationmark.icloud")
}
