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
    ///   - height: Height of progress view. Default = STZ.CRN.Medium
    ///   - isEdgeToEdge: If `NO`, the bar has rounded corner radius. Default = `YES`
    /// - Returns: ProgressView
    public static func Bar(_ progress: Progress,
                           height: Sizeable.Type = STZ.CRN.Medium.self,
                           isEdgeToEdge: Bool = true)
                           -> some View
    {
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
    
    public struct BarMod: ViewModifier {
        private let progress: Progress
        private let isVisible: Bool
        private let height: Sizeable.Type
        private let isEdgeToEdge: Bool
        
        /// Adds a Bar style progress view on top of the modified view
        /// - Parameters:
        ///   - progress: NSProgress object used to fill the progress bar
        ///   - isVisible: Causes the bar to disappear
        ///   - height: Height of progress view. Default = STZ.CRN.Medium
        ///   - isEdgeToEdge: If `NO`, the bar has rounded corner radius. Default = `YES`
        public init(progress: Progress,
                    isVisible: Bool,
                    height: Sizeable.Type = STZ.CRN.Medium.self,
                    isEdgeToEdge: Bool = true)
        {
            self.progress = progress
            self.isVisible = isVisible
            self.height = height
            self.isEdgeToEdge = isEdgeToEdge
        }
        
        public func body(content: Content) -> some View {
            ZStack(alignment: .top) {
                content
                Bar(self.progress, height: self.height, isEdgeToEdge: self.isEdgeToEdge)
                    .opacity(self.isVisible ? 1 : 0)
                    .animation(.default)
            }
        }
    }
}

extension STZ.PRG {
    internal struct LinearStyle: ProgressViewStyle {
        
        let height: Sizeable.Type
        let isEdgeToEdge: Bool
        
        private var cornerRadius: CGFloat {
            self.isEdgeToEdge ? 0 : 100000
        }
        
        func makeBody(configuration config: Configuration) -> some View {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Second view is to put solid background
                    // Setting it with .background left non-rounded corners on mac
                    RoundedRectangle(cornerRadius: self.cornerRadius)
                        .modifier(STZ.CLR.Window.foreground())
                    RoundedRectangle(cornerRadius: self.cornerRadius)
                        .modifier(STZ.CLR.Progress.Background.foreground())
                    RoundedRectangle(cornerRadius: self.cornerRadius)
                        .modifier(STZ.CLR.Progress.Foreground.foreground())
                        .frame(width: self.width(config, geo))
                        .animation(.default)
                }
                .frame(height: self.height.size)
            }
        }
        private func width(_ configuration: Configuration, _ proxy: GeometryProxy) -> CGFloat {
            return CGFloat(configuration.fractionCompleted ?? 0) * proxy.size.width
        }
    }
}
