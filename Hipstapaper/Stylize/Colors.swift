//
//  Created by Jeffrey Bergier on 2020/12/10.
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

public struct PlaceholderColor: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    public var body: Color {
        switch self.colorScheme {
        case .dark:
            return Color(.sRGB, red: 0.2, green: 0.2, blue: 0.2, opacity: 1.0)
        case .light:
            fallthrough
        @unknown default:
            return Color(.sRGB, red: 0.95, green: 0.95, blue: 0.95, opacity: 1.0)
        }
    }
}
