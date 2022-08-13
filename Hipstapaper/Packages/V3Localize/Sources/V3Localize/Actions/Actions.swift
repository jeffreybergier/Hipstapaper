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
    internal static func websiteAdd(_ b: LocalizeBundle) -> ActionLocalization {
        .init(title: b.localized(key: Verb.addWebsite.rawValue),
              hint:  b.localized(key: Phrase.addWebsite.rawValue),
              image: .init(.website),
              shortcut: .commandN)
    }
    internal static func tagAdd(_ b: LocalizeBundle) -> ActionLocalization {
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
}

import Umbrella

extension ActionLabelImage {
    internal init(_ string: Symbol) {
        self = .system(string.rawValue)
    }
}
