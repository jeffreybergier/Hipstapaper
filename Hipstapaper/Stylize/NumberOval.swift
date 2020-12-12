//
//  Created by Jeffrey Bergier on 2020/12/12.
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

public struct NumberOval: View {
    @Environment(\.colorScheme) var colorScheme
    private var number: Int
    public var body: some View {
        Text(String(self.number))
            .font(.callout)
            .foregroundColor(self.colorScheme.isNormal
                                ? .textTitle
                                : .textTitle_Dark)
            .padding(EdgeInsets(top: 3, leading: 8, bottom: 3, trailing: 8))
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(self.colorScheme.isNormal
                            ? Color.numberCircleBackground
                            : Color.numberCircleBackground_Dark)
            )
    }
    public init(_ number: Int) {
        self.number = number
    }
}
