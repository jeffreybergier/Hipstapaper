//
//  Created by Jeffrey Bergier on 2020/12/05.
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

enum Presentation: Int {
    case none
    case search
    case tagApply
    case share
    case addWebsite
    case addTag
    case addChoose
    
    // TODO: Remove this when SwiftUI doesn't suck at modals
    struct Wrap: CustomStringConvertible, CustomDebugStringConvertible {
        var isSearch = false            { didSet { print(debugDescription) } }
        var isTagApply = false          { didSet { print(debugDescription) } }
        var isShare = false             { didSet { print(debugDescription) } }
        var isAddWebsite = false        { didSet { print(debugDescription) } }
        var isAddTag = false            { didSet { print(debugDescription) } }
        var isAddChoose = false         { didSet { print(debugDescription) } }
        
        var description: String {
            return "Presentation: "
            + "isSearch: \(isSearch), "
            + "isTagApply: \(isTagApply), "
            + "isShare: \(isShare), "
            + "isAddWebsite: \(isAddWebsite), "
            + "isAddTag: \(isAddTag), "
            + "isAddChoose: \(isAddChoose)"
        }
        
        var debugDescription: String {
            return "--- Presentation ---\n"
            + "isSearch: \(isSearch)\n"
            + "isTagApply: \(isTagApply)\n"
            + "isShare: \(isShare)\n"
            + "isAddWebsite: \(isAddWebsite)\n"
            + "isAddTag: \(isAddTag)\n"
            + "isAddChoose: \(isAddChoose)"
        }
    }
}
