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
        shortcut: .init(.delete, modifiers: .command)
    )
    internal static let genericDone = Self(
        systemImage: SystemImage.checkmark.rawValue,
        shortcut: .init(.escape)
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
    internal static let tagApply = Self(
        systemImage: SystemImage.tag.rawValue,
        shortcut: .init("I", modifiers: .command)
    )
    internal static let edit = Self(
        systemImage: SystemImage.editPencil.rawValue,
        shortcut: .init(.return, modifiers: .command)
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
    internal static let sortTitleA = Self(
        systemImage: SystemImage.sortTitleA.rawValue,
        shortcut: nil
    )
    internal static let sortTitleZ = Self(
        systemImage: SystemImage.sortTitleZ.rawValue,
        shortcut: nil
    )
    internal static let sortDateNewest = Self(
        systemImage: SystemImage.sortDateNewest.rawValue,
        shortcut: nil
    )
    internal static let sortDateOldest = Self(
        systemImage: SystemImage.sortDateOldest.rawValue,
        shortcut: nil
    )
    internal static let errorPresent = Self(
        systemImage: SystemImage.errorGeneric.rawValue,
        shortcut: nil
    )
    internal static let browseBack = Self(
        systemImage: SystemImage.browseBack.rawValue,
        shortcut: .init("[", modifiers: .command)
    )
    internal static let browseForward = Self(
        systemImage: SystemImage.browseForward.rawValue,
        shortcut: .init("]", modifiers: .command)
    )
    internal static let browseStop = Self(
        systemImage: SystemImage.browseStop.rawValue,
        shortcut: .init(".", modifiers: .command)
    )
    internal static let browseReload = Self(
        systemImage: SystemImage.browseReload.rawValue,
        shortcut: .init("r", modifiers: .command)
    )
    internal static let javascriptYes = Self(
        systemImage: SystemImage.javascriptYes.rawValue,
        shortcut: nil
    )
    internal static let javascriptNo = Self(
        systemImage: SystemImage.javascriptNo.rawValue,
        shortcut: nil
    )
    internal static let autofill = Self(
        systemImage: SystemImage.magic.rawValue,
        shortcut: nil
    )
    internal static let deleteThumbnail = Self(
        systemImage: SystemImage.minusRectangle.rawValue,
        shortcut: nil
    )
    internal static let noContent = Self(
        systemImage: SystemImage.rectangleSlash.rawValue,
        shortcut: nil
    )
}
