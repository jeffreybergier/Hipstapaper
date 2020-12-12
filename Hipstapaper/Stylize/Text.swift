//
//  Created by Jeffrey Bergier on 2020/12/12.
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

internal enum TextProvider {
    case localized(LocalizedStringKey), raw(String)
    var textValue: Text {
        switch self {
        case .localized(let localized):
            return Text(localized)
        case .raw(let raw):
            return Text(raw)
        }
    }
}

extension Text {
    
    public struct IndexRowTitle: View {
        @Environment(\.colorScheme) var colorScheme
        private var provider: TextProvider
        public var body: Text {
            return self.provider.textValue
                .font(.headline)
                .foregroundColor(
                    self.colorScheme.isNormal ? .textTitle : .textTitle_Dark
                )
        }
        public init(_ input: String) { self.provider = .raw(input) }
        public init(_ input: LocalizedStringKey) { self.provider = .localized(input) }
    }
    
    public struct IndexRowTitleDisabled: View {
        @Environment(\.colorScheme) var colorScheme
        private var provider: TextProvider
        public var body: Text {
            return self.provider.textValue
                .font(.headline)
                .foregroundColor(
                    self.colorScheme.isNormal ? .textTitleDisabled : .textTitleDisabled_Dark
                )
        }
        public init(_ input: String) { self.provider = .raw(input) }
        public init(_ input: LocalizedStringKey) { self.provider = .localized(input) }
    }
    
    public struct DetailRowTitle: View {
        @Environment(\.colorScheme) var colorScheme
        private var provider: TextProvider
        public var body: Text {
            return self.provider.textValue
                .font(.headline)
                .foregroundColor(
                    self.colorScheme.isNormal ? .textTitle : .textTitle_Dark
                )
        }
        public init(_ input: String) { self.provider = .raw(input) }
        public init(_ input: LocalizedStringKey) { self.provider = .localized(input) }
    }
    
    public struct DetailRowTitleDisabled: View {
        @Environment(\.colorScheme) var colorScheme
        private var provider: TextProvider
        public var body: Text {
            return self.provider.textValue
                .font(.headline)
                .foregroundColor(
                    self.colorScheme.isNormal ? .textTitleDisabled : .textTitleDisabled_Dark
                )
        }
        public init(_ input: String) { self.provider = .raw(input) }
        public init(_ input: LocalizedStringKey) { self.provider = .localized(input) }
    }
    
    public struct DetailRowSubtitle: View {
        @Environment(\.colorScheme) var colorScheme
        private var provider: TextProvider
        public var body: Text {
            return self.provider.textValue
                .font(.subheadline)
                .foregroundColor(
                    self.colorScheme.isNormal ? .textTitle : .textTitle_Dark
                )
        }
        public init(_ input: String) { self.provider = .raw(input) }
        public init(_ input: LocalizedStringKey) { self.provider = .localized(input) }
    }
}
