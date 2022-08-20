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

// TODO: Turn into ENUM with all constants for the raw values

extension ActionLocalization {
    internal static func convert(raw: ActionLocalization, b: LocalizeBundle) -> ActionLocalization {
        var output = raw
        output.title = b.localized(key: raw.title)
        output.hint = raw.hint.map { b.localized(key: $0) }
        return output
    }
    internal static let raw_openInApp: ActionLocalization = {
        .init(title: Verb.openInApp.rawValue,
              hint:  Phrase.openInApp.rawValue,
              image: .init(.openInApp),
              shortcut: .commandO)
    }()
    internal static func openInApp(_ b: LocalizeBundle) -> ActionLocalization {
        return .convert(raw: raw_openInApp, b: b)
    }
    internal static let raw_openExternal: ActionLocalization = {
        .init(title: Verb.openExternal.rawValue,
              hint:  Phrase.openExternal.rawValue,
              image: .init(.openExternal),
              shortcut: .commandShiftO)
    }()
    internal static func openExternal(_ b: LocalizeBundle) -> ActionLocalization {
        return .convert(raw: raw_openExternal, b: b)
    }
    internal static let raw_addWebsite: ActionLocalization = {
        .init(title: Verb.addWebsite.rawValue,
              hint:  Phrase.addWebsite.rawValue,
              image: .init(.website),
              shortcut: .commandN)
    }()
    internal static func addWebsite(_ b: LocalizeBundle) -> ActionLocalization {
        .convert(raw: .raw_addWebsite, b: b)
    }
    internal static let raw_addTag: ActionLocalization = {
        .init(title: Verb.addTag.rawValue,
              hint:  Phrase.addTag.rawValue,
              image: .init(.tag),
              shortcut: .commandShiftN)
    }()
    internal static func addTag(_ b: LocalizeBundle) -> ActionLocalization {
        .convert(raw: .raw_addTag, b: b)
    }
    internal static func addChoice(_ b: LocalizeBundle) -> ActionLocalization {
        .init(title: b.localized(key: Verb.addChoice.rawValue),
              hint:  b.localized(key: Phrase.addChoice.rawValue),
              image: .init(.plus),
              shortcut: .commandShiftN)
    }
    internal static let raw_editWebsite: ActionLocalization = {
        .init(title: Verb.editWebsite.rawValue,
              hint:  Phrase.editWebsiteTip.rawValue,
              image: .init(.editPencil),
              shortcut: .commandShiftE)
    }()
    internal static func editWebsite(_ b: LocalizeBundle) -> ActionLocalization {
        .convert(raw: .raw_editWebsite, b: b)
    }
    internal static let raw_editTag: ActionLocalization = {
        .init(title: Verb.editTags.rawValue,
              hint:  Phrase.editTag.rawValue,
              image: .init(.editPencil),
              shortcut: .commandOptionE)
    }()
    internal static func editTag(_ b: LocalizeBundle) -> ActionLocalization {
        .convert(raw: .raw_editTag, b: b)
    }
    internal static let raw_deleteWebsite: ActionLocalization = {
        .init(title: Verb.deleteWebsite.rawValue,
              hint:  Phrase.deleteWebsiteTip.rawValue,
              image: .init(.deleteTrash),
              shortcut: .commandDelete)
    }()
    internal static func deleteWebsite(_ b: LocalizeBundle) -> ActionLocalization {
        .convert(raw: .raw_deleteWebsite, b: b)
    }
    internal static var raw_deleteTag: ActionLocalization = {
        .init(title: Verb.deleteTag.rawValue,
              hint:  Phrase.deleteTagTip.rawValue,
              image: .init(.deleteTrash),
              shortcut: .commandOptionDelete)
    }()
    internal static func deleteTag(_ b: LocalizeBundle) -> ActionLocalization {
        .convert(raw: .raw_deleteTag, b: b)
    }
    internal static func deleteThumbnail(_ b: LocalizeBundle) -> ActionLocalization {
        .init(title: b.localized(key: Verb.deleteImage.rawValue),
              hint: b.localized(key: Phrase.deleteImageTip.rawValue),
              image: .init(.minusRectangle),
              shortcut: nil)
    }
    internal static func deleteGeneric(_ b: LocalizeBundle) -> ActionLocalization {
        .init(title: b.localized(key: Verb.deleteGeneric.rawValue),
              hint: nil, // TODO: Add Phrase
              image: .init(.deleteTrash),
              shortcut: .commandDelete)
    }
    // TODO: Change toolbars with DeleteGeneric to pluralize with this
    internal static func deleteAllGeneric(_ b: LocalizeBundle) -> ActionLocalization {
        .init(title: b.localized(key: Verb.deleteAll.rawValue),
              hint: nil, // TODO: Add Phrase
              image: .init(.deleteTrash),
              shortcut: nil)
    }
    internal static func doneGeneric(_ b: LocalizeBundle) -> ActionLocalization {
        .init(title: b.localized(key: Verb.done.rawValue),
              hint: b.localized(key: Phrase.done.rawValue),
              image: .init(.checkmark),
              shortcut: .commandReturn)
    }
    internal static let raw_archiveYes: ActionLocalization = {
        .init(title: Verb.archiveYes.rawValue,
              hint:  Phrase.archive.rawValue,
              image: .init(.archiveYes),
              shortcut: .commandShiftR)
    }()
    internal static func archiveYes(_ b: LocalizeBundle) -> ActionLocalization {
        return .convert(raw: raw_archiveYes, b: b)
    }
    internal static let raw_archiveNo: ActionLocalization = {
        .init(title: Verb.archiveNo.rawValue,
              hint:  Phrase.archive.rawValue,
              image: .init(.archiveNo),
              shortcut: .commandOptionR)
    }()
    internal static func archiveNo(_ b: LocalizeBundle) -> ActionLocalization {
        return .convert(raw: raw_archiveNo, b: b)
    }
    internal static let raw_tagApply: ActionLocalization = {
        .init(title: Verb.tagApply.rawValue,
              hint:  Phrase.addAndRemoveTags.rawValue,
              image: .init(.tag),
              shortcut: .commandY)
    }()
    internal static func tagApply(_ b: LocalizeBundle) -> ActionLocalization {
        .convert(raw: .raw_tagApply, b: b)
    }
    internal static let raw_errorsPresent: ActionLocalization = {
        .init(title: Verb.errorsPresent.rawValue,
              hint:  nil, // TODO: Add Phrase
              image: .init(.errorGeneric),
              shortcut: .commandControlE)
    }()
    internal static func errorsPresent(_ b: LocalizeBundle) -> ActionLocalization {
        .convert(raw: .raw_errorsPresent, b: b)
    }
    internal static let raw_deselectAll: ActionLocalization = {
        .init(title: Verb.deselectAll.rawValue,
              hint:  nil, // TODO: Add Phrase
              image: .init(.tableCellsEmpty),
              shortcut: .commandOptionA)
    }()
    internal static func deselectAll(_ b: LocalizeBundle) -> ActionLocalization {
        .convert(raw: .raw_deselectAll, b: b)
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
    internal static func sort(_ b: LocalizeBundle) -> ActionLocalization {
        .init(title: b.localized(key: Verb.sort.rawValue),
              hint:  b.localized(key: Phrase.sort.rawValue),
              image: .init(.sort),
              shortcut: nil)
    }
    internal static func sortTitleA(_ b: LocalizeBundle) -> ActionLocalization {
        .init(title: b.localized(key: Noun.sortTitleA.rawValue),
              hint:  b.localized(key: Phrase.sortTitleA.rawValue),
              image: .init(.document),
              shortcut: nil)
    }
    internal static func sortTitleZ(_ b: LocalizeBundle) -> ActionLocalization {
        .init(title: b.localized(key: Noun.sortTitleZ.rawValue),
              hint:  b.localized(key: Phrase.sortTitleZ.rawValue),
              image: .init(.documentFill),
              shortcut: nil)
    }
    internal static func sortDateModifiedNewest(_ b: LocalizeBundle) -> ActionLocalization {
        .init(title: b.localized(key: Noun.sortDateModifiedNewest.rawValue),
              hint:  b.localized(key: Phrase.sortDateModifiedNewest.rawValue),
              image: .init(.calendar),
              shortcut: nil)
    }
    internal static func sortDateModifiedOldest(_ b: LocalizeBundle) -> ActionLocalization {
        .init(title: b.localized(key: Noun.sortDateModifiedOldest.rawValue),
              hint:  b.localized(key: Phrase.sortDateModifiedOldest.rawValue),
              image: .init(.calendarFill),
              shortcut: nil)
    }
    internal static func sortDateCreatedNewest(_ b: LocalizeBundle) -> ActionLocalization {
        .init(title: b.localized(key: Noun.sortDateCreatedNewest.rawValue),
              hint:  b.localized(key: Phrase.sortDateCreatedNewest.rawValue),
              image: .init(.calendar),
              shortcut: nil)
    }
    internal static func sortDateCreatedOldest(_ b: LocalizeBundle) -> ActionLocalization {
        .init(title: b.localized(key: Noun.sortDateCreatedOldest.rawValue),
              hint:  b.localized(key: Phrase.sortDateCreatedOldest.rawValue),
              image: .init(.calendarFill),
              shortcut: nil)
    }
    internal static let raw_share: ActionLocalization = {
        .init(title: Verb.share.rawValue,
              hint:  Phrase.share.rawValue,
              image: .init(.share),
              shortcut: .commandShiftI)
    }()
    internal static func share(_ b: LocalizeBundle) -> ActionLocalization {
        .convert(raw: .raw_share, b: b)
    }
    internal static func shareMulti(_ b: LocalizeBundle) -> ActionLocalization {
        .init(title: b.localized(key: Verb.shareAll.rawValue),
              hint:  b.localized(key: Phrase.share.rawValue),
              image: .init(.shareMulti),
              shortcut: nil)
    }
    internal static func shareSingle(_ b: LocalizeBundle) -> ActionLocalization {
        .init(title: b.localized(key: Verb.share.rawValue),
              hint:  b.localized(key: Phrase.share.rawValue),
              image: .init(.share),
              shortcut: nil)
    }
    internal static func shareError(_ b: LocalizeBundle) -> ActionLocalization {
        .init(title: b.localized(key: Verb.share.rawValue),
              image: .init(.shareError),
              shortcut: nil)
    }
    internal static func copyToClipboard(_ b: LocalizeBundle) -> ActionLocalization {
        .init(title: b.localized(key: Verb.copyToClipboard.rawValue),
              hint: b.localized(key: Phrase.copyToClipboard.rawValue),
              image: .init(.paperclip),
              shortcut: nil)
    }
    internal static func filter(_ b: LocalizeBundle) -> ActionLocalization {
        .init(title: b.localized(key: Verb.filter.rawValue),
              hint: b.localized(key: Phrase.filter.rawValue),
              image: .init(.filterNo),
              shortcut: nil)
    }
    internal static func filterYes(_ b: LocalizeBundle) -> ActionLocalization {
        .init(title: b.localized(key: Noun.unreadItems.rawValue),
              hint: b.localized(key: Phrase.filterYes.rawValue),
              image: .init(.filterYes),
              shortcut: nil)
    }
    internal static func filterNo(_ b: LocalizeBundle) -> ActionLocalization {
        .init(title: b.localized(key: Noun.allItems.rawValue),
              hint: b.localized(key: Phrase.filterNo.rawValue),
              image: .init(.filterNo),
              shortcut: nil)
    }
    internal static func columnMenu(_ b: LocalizeBundle) -> ActionLocalization {
        .init(title: b.localized(key: Verb.column.rawValue),
              hint: nil, // TODO: Add Phrase
              image: .init(.filterNo),
              shortcut: nil)
    }
    internal static func columnDateCreated(_ b: LocalizeBundle) -> ActionLocalization {
        .init(title: b.localized(key: Noun.dateCreated.rawValue),
              hint: nil, // TODO: Add Phrase
              image: .init(.columnCircleEmpty),
              shortcut: nil)
    }
    internal static func columnDateModified(_ b: LocalizeBundle) -> ActionLocalization {
        .init(title: b.localized(key: Noun.dateModified.rawValue),
              hint: nil, // TODO: Add Phrase
              image: .init(.columnCircleFill),
              shortcut: nil)
    }
    internal static func browseBack(_ b: LocalizeBundle) -> ActionLocalization {
        .init(title: b.localized(key: Verb.goBack.rawValue),
              hint: b.localized(key: Phrase.goBack.rawValue),
              image: .init(.browseBack),
              shortcut: .commandBraceLeft)
    }
    internal static func browseForward(_ b: LocalizeBundle) -> ActionLocalization {
        .init(title: b.localized(key: Verb.goForward.rawValue),
              hint: b.localized(key: Phrase.goForward.rawValue),
              image: .init(.browseForward),
              shortcut: .commandBraceRight)
    }
    internal static func browseStop(_ b: LocalizeBundle) -> ActionLocalization {
        .init(title: b.localized(key: Verb.stopLoading.rawValue),
              hint: b.localized(key: Phrase.stopLoading.rawValue),
              image: .init(.browseStop),
              shortcut: .commandPeriod)
    }
    internal static func browseReload(_ b: LocalizeBundle) -> ActionLocalization {
        .init(title: b.localized(key: Verb.reloadPage.rawValue),
              hint: b.localized(key: Phrase.reloadPage.rawValue),
              image: .init(.browseReload),
              shortcut: .commandR)
    }
    internal static func javascriptYes(_ b: LocalizeBundle) -> ActionLocalization {
        .init(title: b.localized(key: Verb.javascriptYes.rawValue),
              hint: b.localized(key: Phrase.jsActive.rawValue),
              image: .init(.javascriptYes),
              shortcut: nil)
    }
    internal static func javascriptNo(_ b: LocalizeBundle) -> ActionLocalization {
        .init(title: b.localized(key: Verb.javascriptNo.rawValue),
              hint: b.localized(key: Phrase.jsInactive.rawValue),
              image: .init(.javascriptNo),
              shortcut: nil)
    }
    internal static func autofill(_ b: LocalizeBundle) -> ActionLocalization {
        .init(title: b.localized(key: Verb.autofill.rawValue),
              hint: nil, // TODO: Add Phrase
              image: .init(.magic),
              shortcut: .defaultAction)
    }
    internal static func tabWebsite(_ b: LocalizeBundle) -> ActionLocalization {
        .init(title: b.localized(key: Noun.website.rawValue),
              hint: b.localized(key: Phrase.editWebsiteTip.rawValue),
              image: .init(.website),
              shortcut: nil)
    }
    internal static func tabTag(_ b: LocalizeBundle) -> ActionLocalization {
        .init(title: b.localized(key: Noun.tags.rawValue),
              hint: b.localized(key: Phrase.editTag.rawValue),
              image: .init(.tag),
              shortcut: nil)
    }
}

import Umbrella

extension ActionLabelImage {
    internal init(_ string: Symbol) {
        self = .system(string.rawValue)
    }
}
