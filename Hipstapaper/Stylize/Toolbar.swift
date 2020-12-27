//
//  Created by Jeffrey Bergier on 2020/12/11.
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

#if canImport(AppKit)
import SwiftUI
import AppKit

public struct Toolbar<Content>: View where Content: View {

    private let content: Content

    public var body: some View {
        ZStack {
            ToolbarBackground()
                .ignoresSafeArea()
            self.content
                .paddingToolbar()
                .layoutPriority(1000)
        }
    }
    public init(@ViewBuilder _ content: () -> Content) {
        self.content = content()
    }
}

private struct ToolbarBackground: NSViewRepresentable {
    func updateNSView(_ tb: NSVisualEffectView, context: Context) { }
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .titlebar
        return view
    }
}
#endif
