//
//  Created by Jeffrey Bergier on 2021/01/12.
//
//  Copyright © 2020 Saturday Apps.
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
import Localize

public protocol Presentable: Buttonable {
    /// Title of presented view
    static var noun: Noun { get }
}

extension STZ.TB {
    public enum TagApply: Presentable {
        public static let icon: STZ.ICN? = .tag
        public static let phrase: Phrase = .addAndRemoveTags
        public static let verb: Verb = .addAndRemoveTags
        public static let noun: Noun = .applyTags
        public static let shortcut: KeyboardShortcut? = .init("t", modifiers: [.command, .shift])
    }
    public enum SearchInactive: Presentable {
        public static let icon: STZ.ICN? = .searchInactive
        public static let phrase: Phrase = .searchWebsite
        public static let verb: Verb = .search
        public static let noun: Noun = .search
        public static let shortcut: KeyboardShortcut? = .init("f", modifiers: [.command])
    }
    public enum SearchActive: Presentable {
        public static let icon: STZ.ICN? = .searchActive
        public static let phrase: Phrase = .searchWebsite
        public static let verb: Verb = .search
        public static let noun: Noun = .search
        public static let shortcut: KeyboardShortcut? = .init("f", modifiers: [.command])
    }
    public enum Sort: Presentable {
        public static let icon: STZ.ICN? = .sort
        public static let phrase: Phrase = .sort
        public static let verb: Verb = .sort
        public static let noun: Noun = .sort
        public static let shortcut: KeyboardShortcut? = nil
    }
    public enum AddChoice: Presentable {
        public static let icon: STZ.ICN? = .addPlus
        public static let phrase: Phrase = .addChoice
        public static let verb: Verb = .addChoice
        public static let noun: Noun = .addChoice
        public static let shortcut: KeyboardShortcut? = .init("n", modifiers: [.command])
    }
    public enum AddTag: Presentable {
        public static let icon: STZ.ICN? = .tag
        public static let phrase: Phrase = .addTag
        public static let verb: Verb = .addTag
        public static let noun: Noun = .addTag
        public static let shortcut: KeyboardShortcut? = .init("n", modifiers: [.command, .option])
    }
    public enum AddWebsite: Presentable {
        public static let icon: STZ.ICN? = .addPlus
        public static let phrase: Phrase = .addWebsite
        public static let verb: Verb = .addWebsite
        public static let noun: Noun = .addWebsite
        public static let shortcut: KeyboardShortcut? = .init("n", modifiers: [.command, .shift])
    }
}
