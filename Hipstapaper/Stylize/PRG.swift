//
//  Created by Jeffrey Bergier on 2020/12/20.
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

extension STZ {
    public enum PRG {}
}

extension STZ.PRG {
    public static func Bar(_ progress: Progress) -> some View {
        return ProgressView(progress)
            .progressViewStyle(LinearProgressViewStyle())
    }
    @ViewBuilder public static func Spin(_ progress: Progress?) -> some View {
        if let progress = progress {
            ProgressView(progress)
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(x: 1, y: 0.5, anchor: .center)
        } else {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(x: 0.5, y: 0.5, anchor: .center)
        }
    }
}
