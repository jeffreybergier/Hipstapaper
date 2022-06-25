//
//  Created by Jeffrey Bergier on 2022/06/19.
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

extension Action {
    internal static let tagEdit = Self(
        systemImage: SystemImage.tag.rawValue,
        shortcut: nil
    )
    internal static let tagAdd = Self(
        systemImage: SystemImage.tag.rawValue,
        shortcut: nil
    )
    internal static let websiteAdd = Self(
        systemImage: SystemImage.document.rawValue,
        shortcut: nil
    )
    internal static let genericAdd = Self(
        systemImage: SystemImage.plus.rawValue,
        shortcut: .init("n", modifiers: .command)
    )
    internal static let genericDelete = Self(
        systemImage: SystemImage.deleteTrash.rawValue,
        shortcut: .init("n", modifiers: .command)
    )
    internal static let openInApp = Self(
        systemImage: SystemImage.openInApp.rawValue,
        shortcut: .init("o", modifiers: .command)
    )
    internal static let openExternal = Self(
        systemImage: SystemImage.openExternal.rawValue,
        shortcut: .init("O", modifiers: .command)
    )
    internal static let archiveYes = Self(
        systemImage: SystemImage.archiveYes.rawValue,
        shortcut: .init("a", modifiers: [.command, .control])
    )
    internal static let archiveNo = Self(
        systemImage: SystemImage.archiveNo.rawValue,
        shortcut: .init("u", modifiers: [.command, .control])
    )
    internal static let share = Self(
        systemImage: SystemImage.share.rawValue,
        shortcut: .init("I", modifiers: .command)
    )
    internal static let applyTags = Self(
        systemImage: SystemImage.tag.rawValue,
        shortcut: .init("I", modifiers: .command)
    )
    internal static let edit = Self(
        systemImage: SystemImage.editPencil.rawValue,
        shortcut: .init(.return, modifiers: .command)
    )
    internal static let delete = Self(
        systemImage: SystemImage.deleteTrash.rawValue,
        shortcut: .init(.delete, modifiers: .command)
    )
    internal static let sort = Self(
        systemImage: SystemImage.sort.rawValue,
        shortcut: nil
    )
    internal static let filterYes = Self(
        systemImage: SystemImage.filterYes.rawValue,
        shortcut: nil
    )
    internal static let filterNo = Self(
        systemImage: SystemImage.filterNo.rawValue,
        shortcut: nil
    )
}
