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

internal enum Action {
    case openInApp
    case openExternal
    case addWebsite
    case addTag
    case addChoice
    case editWebsite
    case editTag
    case deleteWebsite
    case deleteTag
    case deleteThumbnail
    case deleteGeneric
    case deleteAllGeneric
    case doneGeneric
    case archiveYes
    case archiveNo
    case tagApply
    case errorsPresent
    case deselectAll
    case noContentWebsite
    case noContentTag
    case noSelectionTag
    case noSelectionWebsite
    case sort
    case sortTitleA
    case sortTitleZ
    case sortDateModifiedNewest
    case sortDateModifiedOldest
    case sortDateCreatedNewest
    case sortDateCreatedOldest
    case share
    case shareMulti
    case shareSingle
    case shareSingleSaved
    case shareSingleCurrent
    case shareError
    case copyToClipboard
    case filter
    case filterYes
    case filterNo
    case columnMenu
    case columnDateCreated
    case columnDateModified
    case browseBack
    case browseForward
    case browseStop
    case browseReload
    case javascriptYes
    case javascriptNo
    case autofill
    case tabWebsite
    case tabTag
    
    internal func localized(_ bundle: LocalizeBundle) -> ActionLocalization {
        var output = self.raw
        output.title = bundle.localized(key: raw.title)
        output.hint = raw.hint.map { bundle.localized(key: $0) }
        return output
    }
    
    private var raw: ActionLocalization {
        switch self {
        case .openInApp:
            return .raw_openInApp
        case .openExternal:
            return .raw_openExternal
        case .addWebsite:
            return .raw_addWebsite
        case .addTag:
            return .raw_addTag
        case .addChoice:
            return .raw_addChoice
        case .editWebsite:
            return .raw_editWebsite
        case .editTag:
            return .raw_editTag
        case .deleteWebsite:
            return .raw_deleteWebsite
        case .deleteTag:
            return .raw_deleteTag
        case .deleteThumbnail:
            return .raw_deleteThumbnail
        case .deleteGeneric:
            return .raw_deleteGeneric
        case .deleteAllGeneric:
            return .raw_deleteAllGeneric
        case .doneGeneric:
            return .raw_doneGeneric
        case .archiveYes:
            return .raw_archiveYes
        case .archiveNo:
            return .raw_archiveNo
        case .tagApply:
            return .raw_tagApply
        case .errorsPresent:
            return .raw_errorsPresent
        case .deselectAll:
            return .raw_deselectAll
        case .noContentWebsite:
            return .raw_noContentWebsite
        case .noContentTag:
            return .raw_noContentTag
        case .noSelectionWebsite:
            return .raw_noSelectionWebsite
        case .noSelectionTag:
            return .raw_noSelectionTag
        case .sort:
            return .raw_sort
        case .sortTitleA:
            return .raw_sortTitleA
        case .sortTitleZ:
            return .raw_sortTitleZ
        case .sortDateModifiedNewest:
            return .raw_sortDateModifiedNewest
        case .sortDateModifiedOldest:
            return .raw_sortDateModifiedOldest
        case .sortDateCreatedNewest:
            return .raw_sortDateCreatedNewest
        case .sortDateCreatedOldest:
            return .raw_sortDateCreatedOldest
        case .share:
            return .raw_share
        case .shareMulti:
            return .raw_shareMulti
        case .shareSingle:
            return .raw_shareSingle
        case .shareSingleSaved:
            return .raw_shareSingleSaved
        case .shareSingleCurrent:
            return .raw_shareSingleCurrent
        case .shareError:
            return .raw_shareError
        case .copyToClipboard:
            return .raw_copyToClipboard
        case .filter:
            return .raw_filter
        case .filterYes:
            return .raw_filterYes
        case .filterNo:
            return .raw_filterNo
        case .columnMenu:
            return .raw_columnMenu
        case .columnDateCreated:
            return .raw_columnDateCreated
        case .columnDateModified:
            return .raw_columnDateModified
        case .browseBack:
            return .raw_browseBack
        case .browseForward:
            return .raw_browseForward
        case .browseStop:
            return .raw_browseStop
        case .browseReload:
            return .raw_browseReload
        case .javascriptYes:
            return .raw_javascriptYes
        case .javascriptNo:
            return .raw_javascriptNo
        case .autofill:
            return .raw_autofill
        case .tabWebsite:
            return .raw_tabWebsite
        case .tabTag:
            return .raw_tabTag
        }
    }
}

extension ActionLocalization {
    fileprivate static let raw_openInApp: ActionLocalization = {
        .init(title: Verb.openInApp.rawValue,
              hint:  Phrase.openInApp.rawValue,
              image: .init(.openInApp),
              shortcut: .commandO)
    }()
    fileprivate static let raw_openExternal: ActionLocalization = {
        .init(title: Verb.openExternal.rawValue,
              hint:  Phrase.openExternal.rawValue,
              image: .init(.openExternal),
              shortcut: .commandShiftO)
    }()
    fileprivate static let raw_addWebsite: ActionLocalization = {
        .init(title: Verb.addWebsite.rawValue,
              hint:  Phrase.addWebsite.rawValue,
              image: .init(.website),
              shortcut: .commandN)
    }()
    fileprivate static let raw_addTag: ActionLocalization = {
        .init(title: Verb.addTag.rawValue,
              hint:  Phrase.addTag.rawValue,
              image: .init(.tag),
              shortcut: .commandShiftN)
    }()
    fileprivate static let raw_addChoice: ActionLocalization = {
        .init(title: Verb.addChoice.rawValue,
              hint:  Phrase.addChoice.rawValue,
              image: .init(.plus),
              shortcut: .commandShiftN)
    }()
    fileprivate static let raw_editWebsite: ActionLocalization = {
        .init(title: Verb.editWebsite.rawValue,
              hint:  Phrase.editWebsiteTip.rawValue,
              image: .init(.editPencil),
              shortcut: .commandShiftE)
    }()
    fileprivate static let raw_editTag: ActionLocalization = {
        .init(title: Verb.editTags.rawValue,
              hint:  Phrase.editTag.rawValue,
              image: .init(.editPencil),
              shortcut: .commandOptionE)
    }()
    fileprivate static let raw_deleteWebsite: ActionLocalization = {
        .init(title: Verb.deleteWebsite.rawValue,
              hint:  Phrase.deleteWebsiteTip.rawValue,
              image: .init(.deleteTrash),
              shortcut: .commandDelete)
    }()
    fileprivate static var raw_deleteTag: ActionLocalization = {
        .init(title: Verb.deleteTag.rawValue,
              hint:  Phrase.deleteTagTip.rawValue,
              image: .init(.deleteTrash),
              shortcut: .commandOptionDelete)
    }()
    fileprivate static let raw_deleteThumbnail: ActionLocalization = {
        .init(title: Verb.deleteImage.rawValue,
              hint: Phrase.deleteImageTip.rawValue,
              image: .init(.minusRectangle),
              shortcut: nil)
    }()
    fileprivate static let raw_deleteGeneric: ActionLocalization = {
        .init(title: Verb.deleteGeneric.rawValue,
              hint: nil, // TODO: Add Phrase
              image: .init(.deleteTrash),
              shortcut: .commandDelete)
    }()
    // TODO: Change toolbars with DeleteGeneric to pluralize with this
    fileprivate static let raw_deleteAllGeneric: ActionLocalization = {
        .init(title: Verb.deleteAll.rawValue,
              hint: nil, // TODO: Add Phrase
              image: .init(.deleteTrash),
              shortcut: nil)
    }()
    fileprivate static let raw_doneGeneric: ActionLocalization = {
        .init(title: Verb.done.rawValue,
              hint: Phrase.done.rawValue,
              image: .init(.checkmark),
              shortcut: .commandReturn)
    }()
    fileprivate static let raw_archiveYes: ActionLocalization = {
        .init(title: Verb.archiveYes.rawValue,
              hint:  Phrase.archive.rawValue,
              image: .init(.archiveYes),
              shortcut: .commandShiftR)
    }()
    fileprivate static let raw_archiveNo: ActionLocalization = {
        .init(title: Verb.archiveNo.rawValue,
              hint:  Phrase.archive.rawValue,
              image: .init(.archiveNo),
              shortcut: .commandOptionR)
    }()
    fileprivate static let raw_tagApply: ActionLocalization = {
        .init(title: Verb.tagApply.rawValue,
              hint:  Phrase.addAndRemoveTags.rawValue,
              image: .init(.tag),
              shortcut: .commandY)
    }()
    fileprivate static let raw_errorsPresent: ActionLocalization = {
        .init(title: Verb.errorsPresent.rawValue,
              hint:  nil, // TODO: Add Phrase
              image: .init(.errorGeneric),
              shortcut: .commandControlE)
    }()
    fileprivate static let raw_deselectAll: ActionLocalization = {
        .init(title: Verb.deselectAll.rawValue,
              hint:  nil, // TODO: Add Phrase
              image: .init(.circleGrid),
              shortcut: .commandEscape)
    }()
    fileprivate static let raw_noContentWebsite: ActionLocalization = {
        .init(title: Phrase.noWebsites.rawValue,
              image: .init(.rectangleSlash))
    }()
    fileprivate static let raw_noContentTag: ActionLocalization = {
        .init(title: Phrase.noTags.rawValue,
              image: .init(.tagSlash))
    }()
    fileprivate static let raw_noSelectionWebsite: ActionLocalization = {
        .init(title: Phrase.noSelectionWebsite.rawValue,
              image: .init(.menu))
    }()
    fileprivate static let raw_noSelectionTag: ActionLocalization = {
        .init(title: Phrase.noSelectionTag.rawValue,
              image: .init(.menu))
    }()
    fileprivate static let raw_sort: ActionLocalization = {
        .init(title: Verb.sort.rawValue,
              hint:  Phrase.sort.rawValue,
              image: .init(.sort),
              shortcut: nil)
    }()
    fileprivate static let raw_sortTitleA: ActionLocalization = {
        .init(title: Noun.sortTitleA.rawValue,
              hint:  Phrase.sortTitleA.rawValue,
              image: .init(.document),
              shortcut: nil)
    }()
    fileprivate static let raw_sortTitleZ: ActionLocalization = {
        .init(title: Noun.sortTitleZ.rawValue,
              hint:  Phrase.sortTitleZ.rawValue,
              image: .init(.documentFill),
              shortcut: nil)
    }()
    fileprivate static let raw_sortDateModifiedNewest: ActionLocalization = {
        .init(title: Noun.sortDateModifiedNewest.rawValue,
              hint:  Phrase.sortDateModifiedNewest.rawValue,
              image: .init(.calendar),
              shortcut: nil)
    }()
    fileprivate static let raw_sortDateModifiedOldest: ActionLocalization = {
        .init(title: Noun.sortDateModifiedOldest.rawValue,
              hint:  Phrase.sortDateModifiedOldest.rawValue,
              image: .init(.calendarFill),
              shortcut: nil)
    }()
    fileprivate static let raw_sortDateCreatedNewest: ActionLocalization = {
        .init(title: Noun.sortDateCreatedNewest.rawValue,
              hint:  Phrase.sortDateCreatedNewest.rawValue,
              image: .init(.calendar),
              shortcut: nil)
    }()
    fileprivate static let raw_sortDateCreatedOldest: ActionLocalization = {
        .init(title: Noun.sortDateCreatedOldest.rawValue,
              hint:  Phrase.sortDateCreatedOldest.rawValue,
              image: .init(.calendarFill),
              shortcut: nil)
    }()
    fileprivate static let raw_share: ActionLocalization = {
        .init(title: Verb.share.rawValue,
              hint:  Phrase.share.rawValue,
              image: .init(.share),
              shortcut: .commandShiftI)
    }()
    fileprivate static let raw_shareMulti: ActionLocalization = {
        .init(title: Verb.shareAll.rawValue,
              hint:  Phrase.share.rawValue,
              image: .init(.shareMulti))
    }()
    fileprivate static let raw_shareSingle: ActionLocalization = {
        .init(title: Verb.share.rawValue,
              image: .init(.share))
    }()
    fileprivate static let raw_shareSingleSaved: ActionLocalization = {
        .init(title: Verb.websiteSaved.rawValue,
              image: .init(.share))
    }()
    fileprivate static let raw_shareSingleCurrent: ActionLocalization = {
        .init(title: Verb.websiteCurrent.rawValue,
              image: .init(.share),
              shortcut: nil)
    }()
    fileprivate static let raw_shareError: ActionLocalization = {
        .init(title: Verb.share.rawValue,
              image: .init(.shareError),
              shortcut: nil)
    }()
    fileprivate static let raw_copyToClipboard: ActionLocalization = {
        .init(title: Verb.copyToClipboard.rawValue,
              hint: Phrase.copyToClipboard.rawValue,
              image: .init(.paperclip),
              shortcut: nil)
    }()
    fileprivate static let raw_filter: ActionLocalization = {
        .init(title: Verb.filter.rawValue,
              hint: Phrase.filter.rawValue,
              image: .init(.filterNo),
              shortcut: nil)
    }()
    fileprivate static let raw_filterYes: ActionLocalization = {
        .init(title: Noun.unreadItems.rawValue,
              hint: Phrase.filterYes.rawValue,
              image: .init(.filterYes),
              shortcut: nil)
    }()
    fileprivate static let raw_filterNo: ActionLocalization = {
        .init(title: Noun.allItems.rawValue,
              hint: Phrase.filterNo.rawValue,
              image: .init(.filterNo),
              shortcut: nil)
    }()
    fileprivate static let raw_columnMenu: ActionLocalization = {
        .init(title: Verb.column.rawValue,
              hint: nil, // TODO: Add Phrase
              image: .init(.filterNo),
              shortcut: nil)
    }()
    fileprivate static let raw_columnDateCreated: ActionLocalization = {
        .init(title: Noun.dateCreated.rawValue,
              hint: nil, // TODO: Add Phrase
              image: .init(.columnCircleEmpty),
              shortcut: nil)
    }()
    fileprivate static let raw_columnDateModified: ActionLocalization = {
        .init(title: Noun.dateModified.rawValue,
              hint: nil, // TODO: Add Phrase
              image: .init(.columnCircleFill),
              shortcut: nil)
    }()
    fileprivate static let raw_browseBack: ActionLocalization = {
        .init(title: Verb.goBack.rawValue,
              hint: Phrase.goBack.rawValue,
              image: .init(.browseBack),
              shortcut: .commandBraceLeft)
    }()
    fileprivate static let raw_browseForward: ActionLocalization = {
        .init(title: Verb.goForward.rawValue,
              hint: Phrase.goForward.rawValue,
              image: .init(.browseForward),
              shortcut: .commandBraceRight)
    }()
    fileprivate static let raw_browseStop: ActionLocalization = {
        .init(title: Verb.stopLoading.rawValue,
              hint: Phrase.stopLoading.rawValue,
              image: .init(.browseStop),
              shortcut: .commandPeriod)
    }()
    fileprivate static let raw_browseReload: ActionLocalization = {
        .init(title: Verb.reloadPage.rawValue,
              hint: Phrase.reloadPage.rawValue,
              image: .init(.browseReload),
              shortcut: .commandR)
    }()
    fileprivate static let raw_javascriptYes: ActionLocalization = {
        .init(title: Verb.javascriptYes.rawValue,
              hint: Phrase.jsActive.rawValue,
              image: .init(.javascriptYes),
              shortcut: nil)
    }()
    fileprivate static let raw_javascriptNo: ActionLocalization = {
        .init(title: Verb.javascriptNo.rawValue,
              hint: Phrase.jsInactive.rawValue,
              image: .init(.javascriptNo),
              shortcut: nil)
    }()
    fileprivate static let raw_autofill: ActionLocalization = {
        .init(title: Verb.autofill.rawValue,
              hint: nil, // TODO: Add Phrase
              image: .init(.magic),
              shortcut: .defaultAction)
    }()
    fileprivate static let raw_tabWebsite: ActionLocalization = {
        .init(title: Noun.website.rawValue,
              hint: Phrase.editWebsiteTip.rawValue,
              image: .init(.website),
              shortcut: nil)
    }()
    fileprivate static let raw_tabTag: ActionLocalization = {
        .init(title: Noun.tags.rawValue,
              hint: Phrase.editTag.rawValue,
              image: .init(.tag),
              shortcut: nil)
    }()
}

import Umbrella

extension ActionLabelImage {
    internal init(_ string: Symbol) {
        self = .system(string.rawValue)
    }
}
