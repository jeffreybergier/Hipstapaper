//
//  Created by Jeffrey Bergier on 2021/01/16.
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

import Datum

enum ModalPresentation: Equatable {
    case none
    case addWebsite
    case addTag
    case addChoose
    case search
    case tagApply
    case share
    case sort
    case browser(AnyElement<AnyWebsite>!)
    
    // TODO: Remove this when SwiftUI doesn't suck at modals
    class Wrap: ObservableObject {
        @Published var isSearch = false {
            didSet {
                guard !internalUpdateInProgress else { return }
                guard !self.isSearch else { return }
                self.value = .none
            }
        }
        
        @Published var isTagApply = false {
            didSet {
                guard !internalUpdateInProgress else { return }
                guard !self.isTagApply else { return }
                self.value = .none
            }
        }
        
        @Published var isShare = false {
            didSet {
                guard !internalUpdateInProgress else { return }
                guard !self.isShare else { return }
                self.value = .none
            }
        }
        
        @Published var isSort = false {
            didSet {
                guard !internalUpdateInProgress else { return }
                guard !self.isSort else { return }
                self.value = .none
            }
        }
        
        @Published var isAddWebsite = false {
            didSet {
                guard !internalUpdateInProgress else { return }
                guard !self.isAddWebsite else { return }
                self.value = .none
            }
        }
        
        @Published var isAddTag = false {
            didSet {
                guard !internalUpdateInProgress else { return }
                guard !self.isAddTag else { return }
                self.value = .none
            }
        }
        
        @Published var isAddChoose = false {
            didSet {
                guard !internalUpdateInProgress else { return }
                guard !self.isAddChoose else { return }
                self.value = .none
            }
        }
        
        @Published var isBrowser = false {
            didSet {
                guard !internalUpdateInProgress else { return }
                guard !self.isBrowser else { return }
                self.value = .none
            }
        }
        
        var browserItem: AnyElement<AnyWebsite>! {
            guard case .browser(let item) = self.value else { return nil }
            return item
        }
        
        private var internalUpdateInProgress = false
        @Published var value: ModalPresentation = .none {
            didSet {
                self.internalUpdateInProgress = true
                defer { self.internalUpdateInProgress = false }
                
                self.isSearch     = self.value.isCase(of: .search)
                self.isTagApply   = self.value.isCase(of: .tagApply)
                self.isShare      = self.value.isCase(of: .share)
                self.isSort       = self.value.isCase(of: .sort)
                self.isAddWebsite = self.value.isCase(of: .addWebsite)
                self.isAddTag     = self.value.isCase(of: .addTag)
                self.isAddChoose  = self.value.isCase(of: .addChoose)
                self.isBrowser    = self.value.isCase(of: .browser(nil))
            }
        }
    }
}

extension ModalPresentation {
    func isCase(of rhs: ModalPresentation) -> Bool {
        switch self {
        case .none:
            guard case .none = rhs else { return false }
        case .search:
            guard case .search = rhs else { return false }
        case .tagApply:
            guard case .tagApply = rhs else { return false }
        case .share:
            guard case .share = rhs else { return false }
        case .sort:
            guard case .sort = rhs else { return false }
        case .browser:
            guard case .browser = rhs else { return false }
        case .addWebsite:
            guard case .addWebsite = rhs else { return false }
        case .addTag:
            guard case .addTag = rhs else { return false }
        case .addChoose:
            guard case .addChoose = rhs else { return false }
        }
        return true
    }
}