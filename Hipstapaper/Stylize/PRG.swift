//
//  Created by Jeffrey Bergier on 2020/12/20.
//
//  MIT License
//
//  Copyright (c) 2021 Jeffrey Bergier
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
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
