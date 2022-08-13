//
//  Created by Jeffrey Bergier on 2022/08/12.
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

import Umbrella

extension ActionLocalization {
    internal static func openInApp(_ b: LocalizeBundle) -> ActionLocalization {
        .init(title: b.localized(key: Verb.openInApp.rawValue),
              hint:  b.localized(key: Phrase.openInApp.rawValue),
              image: .init(.openInApp),
              shortcut: .commandO)
    }
    internal static func openExternal(_ b: LocalizeBundle) -> ActionLocalization {
        .init(title: b.localized(key: Verb.openExternal.rawValue),
              hint:  b.localized(key: Phrase.openExternal.rawValue),
              image: .init(.openExternal),
              shortcut: .commandShiftO)
    }
    internal static func addWebsite(_ b: LocalizeBundle) -> ActionLocalization {
        .init(title: b.localized(key: Verb.addWebsite.rawValue),
              hint:  b.localized(key: Phrase.addWebsite.rawValue),
              image: .init(.website),
              shortcut: .commandN)
    }
    internal static func addTag(_ b: LocalizeBundle) -> ActionLocalization {
        .init(title: b.localized(key: Verb.addTag.rawValue),
              hint:  b.localized(key: Phrase.addTag.rawValue),
              image: .init(.tag),
              shortcut: .commandShiftN)
    }
    internal static func addChoice(_ b: LocalizeBundle) -> ActionLocalization {
        .init(title: b.localized(key: Verb.addChoice.rawValue),
              hint:  b.localized(key: Phrase.addChoice.rawValue),
              image: .init(.plus),
              shortcut: .commandShiftN)
    }
    internal static func editWebsite(_ b: LocalizeBundle) -> ActionLocalization {
        .init(title: b.localized(key: Verb.editWebsite.rawValue),
              hint:  b.localized(key: Phrase.editWebsiteTip.rawValue),
              image: .init(.editPencil),
              shortcut: .commandShiftE)
    }
    internal static func editTag(_ b: LocalizeBundle) -> ActionLocalization {
        .init(title: b.localized(key: Verb.editTags.rawValue),
              hint:  b.localized(key: Phrase.editTag.rawValue),
              image: .init(.editPencil),
              shortcut: .commandOptionE)
    }
    internal static func deleteWebsite(_ b: LocalizeBundle) -> ActionLocalization {
        .init(title: b.localized(key: Verb.deleteWebsite.rawValue),
              hint:  b.localized(key: Phrase.deleteWebsiteTip.rawValue),
              image: .init(.deleteTrash),
              shortcut: .commandDelete)
    }
    internal static func deleteTag(_ b: LocalizeBundle) -> ActionLocalization {
        .init(title: b.localized(key: Verb.deleteTag.rawValue),
              hint:  b.localized(key: Phrase.deleteTagTip.rawValue),
              image: .init(.deleteTrash),
              shortcut: .commandDelete)
    }
    internal static func archiveYes(_ b: LocalizeBundle) -> ActionLocalization {
        .init(title: b.localized(key: Verb.archiveYes.rawValue),
              hint:  b.localized(key: Phrase.archive.rawValue),
              image: .init(.archiveYes),
              shortcut: .commandShiftR)
    }
    internal static func archiveNo(_ b: LocalizeBundle) -> ActionLocalization {
        .init(title: b.localized(key: Verb.archiveNo.rawValue),
              hint:  b.localized(key: Phrase.archive.rawValue),
              image: .init(.archiveNo),
              shortcut: .commandOptionR)
    }
    internal static func share(_ b: LocalizeBundle) -> ActionLocalization {
        .init(title: b.localized(key: Verb.share.rawValue),
              hint:  b.localized(key: Phrase.share.rawValue),
              image: .init(.share),
              shortcut: .commandShiftI)
    }
    internal static func tagApply(_ b: LocalizeBundle) -> ActionLocalization {
        .init(title: b.localized(key: Verb.tagApply.rawValue),
              hint:  b.localized(key: Phrase.addAndRemoveTags.rawValue),
              image: .init(.tag),
              shortcut: .commandY)
    }
    internal static func errorsPresent(_ b: LocalizeBundle) -> ActionLocalization {
        .init(title: b.localized(key: Verb.errorsPresent.rawValue),
              hint:  nil, // b.localized(key: Phrase.errorsPresent.rawValue) TODO: Phrase
              image: .init(.errorGeneric),
              shortcut: .commandControlE)
    }
    internal static func selectAll(_ b: LocalizeBundle) -> ActionLocalization {
        .init(title: b.localized(key: Verb.selectAll.rawValue),
              hint:  nil, // b.localized(key: Phrase.errorsPresent.rawValue) TODO: Phrase
              image: .init(.tableCellsFill),
              shortcut: .commandOptionA)
    }
    internal static func deselectAll(_ b: LocalizeBundle) -> ActionLocalization {
        .init(title: b.localized(key: Verb.deselectAll.rawValue),
              hint:  nil, // b.localized(key: Phrase.errorsPresent.rawValue) TODO: Phrase
              image: .init(.tableCellsEmpty),
              shortcut: .commandOptionA)
    }
    internal static func noContentWebsite(_ b: LocalizeBundle) -> ActionLocalization {
        .init(title: b.localized(key: Phrase.noWebsites.rawValue),
              image: .init(.rectangleSlash))
    }
    internal static func noContentTag(_ b: LocalizeBundle) -> ActionLocalization {
        .init(title: b.localized(key: Phrase.noTags.rawValue),
              image: .init(.tagSlash))
    }
    internal static func noSelectionWebsite(_ b: LocalizeBundle) -> ActionLocalization {
        .init(title: b.localized(key: Phrase.noSelectionWebsite.rawValue),
              image: .init(.menu))
    }
    internal static func noSelectionTag(_ b: LocalizeBundle) -> ActionLocalization {
        .init(title: b.localized(key: Phrase.noSelectionTag.rawValue),
              image: .init(.menu))
    }
//    internal static func sort(_ b: LocalizeBundle) -> ActionLocalization {
//        .init(title: b.localized(key: Verb.sort.rawValue),
//              hint:  b.localized(key: Phrase.sort.rawValue),
//              image: .init(.sort),
//              shortcut: nil)
//    }
}

import Umbrella

extension ActionLabelImage {
    internal init(_ string: Symbol) {
        self = .system(string.rawValue)
    }
}
