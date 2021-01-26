//
//  Created by Jeffrey Bergier on 2021/01/14.
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
    public enum VIEW {
        public struct isFallBackKey: PreferenceKey {
            public static var defaultValue: Bool = false
            public static func reduce(value: inout Bool, nextValue: () -> Bool) {
                value = nextValue()
            }
        }
    }
}

extension STZ.VIEW {
    public static func TXT(_ string: String?, or fallback: LocalizedStringKey) -> some View {
        if let string = string {
            return Text(string)
                .preference(key: isFallBackKey.self, value: false)
        } else {
            return Text(fallback)
                .preference(key: isFallBackKey.self, value: true)
        }
    }
    public static func TXT(_ string: String) -> Text {
        return Text(string)
    }
    public static func TXT(_ localized: LocalizedStringKey) -> Text {
        return Text(localized)
    }
}

extension STZ.VIEW {
    public struct NumberOval: View {
        public let number: Int
        public var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 1000) // Setting super large number seems to give desired appearance
                    .modifier(STZ.CLR.Oval.Background.foreground())
                STZ.VIEW.TXT(String(self.number))
                    .modifier(STZ.FNT.Oval.apply())
                    .modifier(STZ.CLR.Oval.Text.foreground())
                    .modifier(STZ.PDG.Oval())
                    .layoutPriority(1)
            }
        }
        public init(_ number: Int) {
            self.number = number
        }
    }
}

#if os(macOS)
import AppKit
extension STZ.VIEW {
    // TODO: Delete this once mac supports toolbars properly
    public struct TB_HACK: ViewModifier {
        public init() {}
        public func body(content: Content) -> some View {
            ZStack {
                ToolbarBackground()
                    .ignoresSafeArea()
                content
                    .modifier(STZ.PDG.TB())
                    .layoutPriority(1)
            }
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
}
#endif
