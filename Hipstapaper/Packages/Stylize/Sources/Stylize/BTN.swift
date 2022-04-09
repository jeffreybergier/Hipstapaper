//
//  Created by Jeffrey Bergier on 2021/01/11.
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
import Localize

internal struct DefaultButtonStyle: ViewModifier {
    internal func body(content: Content) -> some View {
        #if os(macOS)
        return content.buttonStyle(BorderedButtonStyle())
        #else
        return content
        #endif
    }
}

internal struct DoneStyle: ViewModifier {
    internal var enabled: Bool
    internal func body(content: Content) -> some View {
        if self.enabled {
            return content
                .modifier(STZ.FNT.Button.Done.apply())
        } else {
            return content
                .modifier(STZ.FNT.Button.Default.apply())
        }
    }
}

internal struct Shortcut: ViewModifier {
    internal var shortcut: KeyboardShortcut?
    internal init(_ shortcut: KeyboardShortcut?) {
        self.shortcut = shortcut
    }
    @ViewBuilder internal func body(content: Content) -> some View {
        if let shortcut = self.shortcut {
            content.keyboardShortcut(shortcut)
        } else {
            content
        }
    }
}

extension STZ {
    public enum BTN {
        public enum Go: Buttonable {
            public static var icon: STZ.ICN? = nil
            public static var phrase: Phrase = .loadPage
            public static var verb: Verb = .go
            public static var shortcut: KeyboardShortcut? = .init(.defaultAction)
        }
        public enum Stop: Buttonable {
            public static var icon: STZ.ICN? = .stop
            public static var phrase: Phrase = .stopLoading
            public static var verb: Verb = .stopLoading
            public static var shortcut: KeyboardShortcut? = nil
        }
        public enum Done: Buttonable {
            public static var icon: STZ.ICN? = nil
            public static var phrase: Phrase = .done
            public static var verb: Verb = .done
            public static var shortcut: KeyboardShortcut? = .init(.defaultAction)
        }
        public enum BrowserDone: Buttonable {
            public static var icon: STZ.ICN? = nil
            public static var phrase: Phrase = .done
            public static var verb: Verb = .done
            public static var shortcut: KeyboardShortcut? = .init("w")
        }
        public enum Save: Buttonable {
            public static var icon: STZ.ICN? = nil
            public static var phrase: Phrase = .save
            public static var verb: Verb = .save
            public static var shortcut: KeyboardShortcut? = .init(.defaultAction)
        }
        public enum Cancel: Buttonable {
            public static var icon: STZ.ICN? = nil
            public static var phrase: Phrase = .cancel
            public static var verb: Verb = .cancel
            public static var shortcut: KeyboardShortcut? = .init(.cancelAction)
        }
    }
}
