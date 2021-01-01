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

enum DetailToolbarPresentation: Int {
    case none
    case search
    case tagApply
    case share
    case browser
    case sort
    
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
        
        var isBrowser = false {
            didSet {
                guard !internalUpdateInProgress else { return }
                guard !self.isBrowser else { return }
                self.value = .none
            }
        }
        
        var isSort = false {
            didSet {
                guard !internalUpdateInProgress else { return }
                guard !self.isSort else { return }
                self.value = .none
            }
        }
        
        private var internalUpdateInProgress = false
        var value: DetailToolbarPresentation = .none {
            didSet {
                self.internalUpdateInProgress = true
                defer { self.internalUpdateInProgress = false }
                
                self.isSearch     = self.value == .search
                self.isTagApply   = self.value == .tagApply
                self.isShare      = self.value == .share
                self.isBrowser    = self.value == .browser
                self.isSort       = self.value == .sort
            }
        }
    }
}
