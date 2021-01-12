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
    static var noun: LocalizedStringKey { get }
}

extension STZ.TB {
    public enum TagApply: Presentable {
        public static let icon: String? = "tag"
        public static let phrase: LocalizedStringKey = Verb.AddAndRemoveTags
        public static let verb: LocalizedStringKey = Verb.AddAndRemoveTags
        public static let noun: LocalizedStringKey = Noun.ApplyTags
        public static let shortcut: KeyboardShortcut? = .init("t", modifiers: [.command, .shift])
    }
    public enum SearchInactive: Presentable {
        public static let icon: String? = "magnifyingglass"
        public static let phrase: LocalizedStringKey = Verb.Search
        public static let verb: LocalizedStringKey = Verb.Search
        public static let noun: LocalizedStringKey = Noun.Search
        public static let shortcut: KeyboardShortcut? = .init("f", modifiers: [.command])
    }
    public enum SearchActive: Presentable {
        public static let icon: String? = "magnifyingglass.circle.fill"
        public static let phrase: LocalizedStringKey = Verb.Search
        public static let verb: LocalizedStringKey = Verb.Search
        public static let noun: LocalizedStringKey = Noun.Search
        public static let shortcut: KeyboardShortcut? = .init("f", modifiers: [.command])
    }
    public enum Sort: Presentable {
        public static let icon: String? = "arrow.up.arrow.down.circle"
        public static let phrase: LocalizedStringKey = Phrase.Sort
        public static let verb: LocalizedStringKey = Phrase.Sort
        public static let noun: LocalizedStringKey = Noun.Sort
        public static let shortcut: KeyboardShortcut? = nil
    }
    public enum AddChoice: Presentable {
        public static let icon: String? = "plus"
        public static let phrase: LocalizedStringKey = Phrase.AddChoice
        public static let verb: LocalizedStringKey = Phrase.AddChoice
        public static let noun: LocalizedStringKey = Phrase.AddChoice
        public static let shortcut: KeyboardShortcut? = .init("n", modifiers: [.command])
    }
    public enum AddTag: Presentable {
        public static let icon: String? = "tag"
        public static let phrase: LocalizedStringKey = Verb.AddTag
        public static let verb: LocalizedStringKey = Verb.AddTag
        public static let noun: LocalizedStringKey = { fatalError() }()
        public static let shortcut: KeyboardShortcut? = .init("n", modifiers: [.command, .option])
    }
    public enum AddWebsite: Presentable {
        public static let icon: String? = "macwindow.badge.plus"
        public static let phrase: LocalizedStringKey = Verb.AddWebsite
        public static let verb: LocalizedStringKey = Verb.AddWebsite
        public static let noun: LocalizedStringKey = { fatalError() }()
        public static let shortcut: KeyboardShortcut? = .init("n", modifiers: [.command, .shift])
    }
}
