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
    case browser
    
    // TODO: Remove this when SwiftUI doesn't suck at modals
    struct Wrap {
        var isSearch = false {
            didSet {
                guard !internalUpdateInProgress else { return }
                guard !self.isSearch else { return }
                self.value = .none
            }
        }
        
        var isTagApply = false {
            didSet {
                guard !internalUpdateInProgress else { return }
                guard !self.isTagApply else { return }
                self.value = .none
            }
        }
        
        var isShare = false {
            didSet {
                guard !internalUpdateInProgress else { return }
                guard !self.isShare else { return }
                self.value = .none
            }
        }
        
        var isAddWebsite = false {
            didSet {
                guard !internalUpdateInProgress else { return }
                guard !self.isAddWebsite else { return }
                self.value = .none
            }
        }
        
        var isAddTag = false {
            didSet {
                guard !internalUpdateInProgress else { return }
                guard !self.isAddTag else { return }
                self.value = .none
            }
        }
        
        var isAddChoose = false {
            didSet {
                guard !internalUpdateInProgress else { return }
                guard !self.isAddChoose else { return }
                self.value = .none
            }
        }
        
        var isBrowser = false {
            didSet {
                guard !internalUpdateInProgress else { return }
                guard !self.isBrowser else { return }
                self.value = .none
            }
        }
        
        private var internalUpdateInProgress = false
        var value: Presentation = .none {
            didSet {
                self.internalUpdateInProgress = true
                defer { self.internalUpdateInProgress = false }
                
                self.isSearch     = self.value == .search
                self.isTagApply   = self.value == .tagApply
                self.isShare      = self.value == .share
                self.isAddWebsite = self.value == .addWebsite
                self.isAddTag     = self.value == .addTag
                self.isAddChoose  = self.value == .addChoose
                self.isBrowser    = self.value == .browser
            }
        }
    }
}
