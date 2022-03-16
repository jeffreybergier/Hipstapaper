//
//  Created by Jeffrey Bergier on 2021/01/16.
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

import Foundation
import Datum2
import Umbrella

enum ModalPresentation: Equatable {
    case none
    case addWebsite
    case addChoose
    case search
    case sort
    case tagName(TH.Selection)
    case tagApply(WH.Selection)
    case share(WH.Selection)
    case browser(Website)
    
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
        
        @Published var isTagName: IdentBox<TH.Selection>? = nil {
            didSet {
                guard !internalUpdateInProgress else { return }
                guard self.isTagName == nil else { return }
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
        
        @Published var isShare: IdentBox<WH.Selection>? {
            didSet {
                guard !self.internalUpdateInProgress else { return }
                guard self.isShare == nil else { return }
                self.value = .none
            }
        }
        
        @Published var isTagApply: IdentBox<WH.Selection>? {
            didSet {
                guard !internalUpdateInProgress else { return }
                guard self.isTagApply == nil else { return }
                self.value = .none
            }
        }
        
        @Published var isBrowser: Website? {
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
                
                self.isSearch        = false
                self.isSort          = false
                self.isAddWebsite    = false
                self.isAddChoose     = false
                self.isTagName       = nil
                self.isTagApply      = nil
                self.isBrowser       = nil
                self.isShare         = nil
                switch self.value {
                case .none:
                    break
                case .tagApply(let selection):
                    self.isTagApply = .init(selection)
                case .share(let selection):
                    self.isShare = .init(selection)
                case .browser(let item):
                    self.isBrowser = item
                case .addWebsite:
                    self.isAddWebsite = true
                case .tagName(let item):
                    self.isTagName = .init(item)
                case .addChoose:
                    self.isAddChoose = true
                case .search:
                    self.isSearch = true
                case .sort:
                    self.isSort = true
                }
            }
        }
    }
}
