//
//  Created by Jeffrey Bergier on 2020/11/30.
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

public enum Sort: Int, CaseIterable, Identifiable, Hashable, Codable {
    public var id: Int { self.rawValue }
    public static let `default`: Sort = .dateCreatedNewest
    case dateCreatedNewest, dateCreatedOldest
    case dateModifiedNewest, dateModifiedOldest
    case titleA, titleZ
}

extension Sort: SortComparator {
        
    public var order: SortOrder {
        get {
            switch self {
            case .dateCreatedOldest, .dateModifiedOldest, .titleZ:
                return .forward
            case .dateCreatedNewest, .dateModifiedNewest, .titleA:
                return .reverse
            }
        }
        set {
            switch self {
            case .dateCreatedNewest, .dateCreatedOldest:
                switch newValue {
                case .forward:
                    self = .dateCreatedOldest
                case .reverse:
                    self = .dateCreatedNewest
                }
            case .dateModifiedNewest, .dateModifiedOldest:
                switch newValue {
                case .forward:
                    self = .dateModifiedOldest
                case .reverse:
                    self = .dateModifiedNewest
                }
            case .titleA, .titleZ:
                switch newValue {
                case .forward:
                    self = .titleZ
                case .reverse:
                    self = .titleA
                }
            }
        }
    }
    
    public func compare(_ lhs: Website, _ rhs: Website) -> ComparisonResult {
        fatalError()
    }
}
