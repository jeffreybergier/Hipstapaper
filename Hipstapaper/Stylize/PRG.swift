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
    /// Stylized Progress View
    /// - Parameters:
    ///   - progress: NSProgress object used to fill the progress bar
    ///   - height: Height of progress view. Default = 6
    ///   - isEdgeToEdge: If `NO`, the bar has rounded corner radius.
    /// - Returns: ProgressView
    public static func Bar(_ progress: Progress, height: CGFloat = 6, isEdgeToEdge: Bool) -> some View {
        return ProgressView(progress)
            .progressViewStyle(LinearStyle(height: height, isEdgeToEdge: isEdgeToEdge))
    }
    @ViewBuilder public static func Spin(_ progress: Progress?) -> some View {
        if let progress = progress {
            ProgressView(progress)
                .progressViewStyle(CircularProgressViewStyle())
        } else {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
        }
    }
}

extension STZ.PRG {
    internal struct LinearStyle: ProgressViewStyle {
        
        let height: CGFloat
        let isEdgeToEdge: Bool
        
        func makeBody(configuration config: Configuration) -> some View {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    STZ.CLR.Progress.Background.view()
                    STZ.CLR.Progress.Foreground.view()
                        .frame(width: self.width(config, geo))
                        .animation(.default)
                }
                .frame(height: self.height)
                .cornerRadius(self.isEdgeToEdge ? 0 : self.height / 2)
            }
        }
        private func width(_ configuration: Configuration, _ proxy: GeometryProxy) -> CGFloat {
            return CGFloat(configuration.fractionCompleted ?? 0) * proxy.size.width
        }
    }
}
