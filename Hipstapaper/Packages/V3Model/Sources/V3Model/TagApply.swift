//
//  Created by Jeffrey Bergier on 2022/03/18.
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

public struct TagApply: Identifiable, Hashable {
    
    public var id: Tag.Identifier { self.tag.id }
    public var tag: Tag
    public var status: Status
    
    public init(tag: Tag, status: Status) {
        self.tag = tag
        self.status = status
    }
    
    public enum Status: Hashable, Codable {
        case all, some, none
        
        public var boolValue: Bool {
            get {
                switch self {
                case .none: return false
                case .all, .some: return true
                }
            }
            set {
                switch newValue {
                case true:
                    self = .all
                case false:
                    self = .none
                }
            }
        }
    }
}
