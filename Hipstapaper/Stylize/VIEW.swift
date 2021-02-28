//
//  Created by Jeffrey Bergier on 2021/01/14.
//
//  MIT License
//
//  Copyright (c) 2021 jeffreybergier
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
    public enum VIEW {}
}

extension STZ {
    public struct isFallbackKey: PreferenceKey {
        public static var defaultValue: Bool = false
        public static func reduce(value: inout Bool, nextValue: () -> Bool) {
            value = nextValue()
        }
    }
}

extension STZ.VIEW {
    @ViewBuilder public static func TXT(_ string: String?, or fallback: LocalizedStringKey) -> some View {
        if let string = string {
            Text(string)
                .lineLimit(1)
        } else {
            Text(fallback)
                .preference(key: STZ.isFallbackKey.self, value: true)
                .lineLimit(1)
        }
    }
    public static func TXT(_ string: String) -> some View {
        return Text(string)
            .lineLimit(1)
    }
    public static func TXT(_ localized: LocalizedStringKey) -> some View {
        return Text(localized)
            .lineLimit(1)
    }
}

extension STZ.VIEW {
    public struct NumberOval: View {
        public let number: Int
        public var body: some View {
            Oval {
                STZ.VIEW.TXT(String(self.number))
                    .modifier(STZ.FNT.Oval.apply())
            }
        }
        public init(_ number: Int) {
            self.number = number
        }
    }
    public struct Oval<Child: View>: View {
        private let childBuilder: () -> Child
        public init(@ViewBuilder _ builder: @escaping () -> Child) {
            self.childBuilder = builder
        }
        public var body: some View {
            ZStack {
                // Second view is to put solid background
                // Setting it with .background left non-rounded corners on mac
                RoundedRectangle(cornerRadius: 1000)
                    .modifier(STZ.CLR.Window.foreground())
                RoundedRectangle(cornerRadius: 1000) // Setting super large number seems to give desired appearance
                    .modifier(STZ.CLR.Oval.Background.foreground())
                self.childBuilder()
                    .modifier(STZ.PDG.Oval())
                    .modifier(STZ.CLR.Oval.Text.foreground())
                    .layoutPriority(1)
            }
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
                // ToolbarBackground().ignoresSafeArea()
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
