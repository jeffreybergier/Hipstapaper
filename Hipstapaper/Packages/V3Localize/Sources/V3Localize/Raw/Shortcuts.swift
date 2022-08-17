//
//  Created by Jeffrey Bergier on 2022/08/13.
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

extension KeyboardShortcut {
    internal static let commandO            = KeyboardShortcut("o", modifiers: [.command])
    internal static let commandShiftO       = KeyboardShortcut("o", modifiers: [.command, .shift])
    internal static let commandN            = KeyboardShortcut("n", modifiers: [.command])
    internal static let commandShiftN       = KeyboardShortcut("n", modifiers: [.command, .shift])
    // TODO: Change to Command A
    internal static let commandShiftA       = KeyboardShortcut("a", modifiers: [.command, .shift])
    // TODO: Change to Command Shift A
    internal static let commandOptionA      = KeyboardShortcut("a", modifiers: [.command, .option])
    internal static let commandShiftE       = KeyboardShortcut("e", modifiers: [.command, .shift])
    internal static let commandOptionE      = KeyboardShortcut("e", modifiers: [.command, .option])
    internal static let commandControlE     = KeyboardShortcut("e", modifiers: [.command, .control])
    internal static let commandR            = KeyboardShortcut("r", modifiers: [.command])
    internal static let commandShiftR       = KeyboardShortcut("r", modifiers: [.command, .shift])
    internal static let commandOptionR      = KeyboardShortcut("r", modifiers: [.command, .option])
    internal static let commandShiftI       = KeyboardShortcut("i", modifiers: [.command, .shift])
    internal static let commandY            = KeyboardShortcut("y", modifiers: [.command])
    internal static let commandReturn       = KeyboardShortcut(.return, modifiers: [.command])
    internal static let commandBraceLeft    = KeyboardShortcut("[", modifiers: [.command])
    internal static let commandBraceRight   = KeyboardShortcut("]", modifiers: [.command])
    internal static let commandPeriod       = KeyboardShortcut(".", modifiers: [.command])
    internal static let commandDelete       = KeyboardShortcut(.delete, modifiers: [.command])
    internal static let commandOptionDelete = KeyboardShortcut(.delete, modifiers: [.command, .option])
}
