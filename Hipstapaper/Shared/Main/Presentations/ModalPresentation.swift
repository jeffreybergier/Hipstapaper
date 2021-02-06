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
    case tagApply(WH.Selection)
    case share(WH.Selection)
    case sort
    case delete(WH.Selection)
    case browser(AnyElementObserver<AnyWebsite>)
    
    // TODO: Remove this when SwiftUI doesn't suck at modals
    class Wrap: ObservableObject {
        @Published var isSearch = false {
            didSet {
                guard !internalUpdateInProgress else { return }
                guard !self.isSearch else { return }
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
        
        @Published var isDelete: WH.Selection? {
            didSet {
                guard !self.internalUpdateInProgress else { return }
                guard self.isDelete == nil else { return }
                self.value = .none
            }
        }
        
        @Published var isShare: WH.Selection? {
            didSet {
                guard !self.internalUpdateInProgress else { return }
                guard self.isShare == nil else { return }
                self.value = .none
            }
        }
        
        @Published var isTagApply: WH.Selection? {
            didSet {
                guard !internalUpdateInProgress else { return }
                guard self.isTagApply == nil else { return }
                self.value = .none
            }
        }
        
        @Published var isBrowser: BlackBox<AnyElementObserver<AnyWebsite>>? {
            didSet {
                guard !self.internalUpdateInProgress else { return }
                guard self.isBrowser == nil else { return }
                self.value = .none
            }
        }
        
        private var internalUpdateInProgress = false
        @Published var value: ModalPresentation = .none {
            didSet {
                self.internalUpdateInProgress = true
                defer { self.internalUpdateInProgress = false }
                
                self.isSearch     = self.value.isCase(of: .search)
                self.isSort       = self.value.isCase(of: .sort)
                self.isAddWebsite = self.value.isCase(of: .addWebsite)
                self.isAddTag     = self.value.isCase(of: .addTag)
                self.isAddChoose  = self.value.isCase(of: .addChoose)
                
                self.isDelete     = nil
                self.isTagApply   = nil
                self.isBrowser    = nil
                self.isShare      = nil
                switch self.value {
                case .delete(let selection):
                    self.isDelete = selection
                case .tagApply(let selection):
                    self.isTagApply = selection
                case .share(let selection):
                    self.isShare = selection
                case .browser(let item):
                    self.isBrowser = .init(item)
                default:
                    break
                }
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
        case .delete:
            guard case .delete = rhs else { return false }
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
