//
//  Created by Jeffrey Bergier on 2021/01/12.
//
//  MIT License
//
//  Copyright (c) 2021 jeffreybergier
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
