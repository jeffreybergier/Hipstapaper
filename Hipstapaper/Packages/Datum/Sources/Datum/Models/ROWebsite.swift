//
//  Created by Jeffrey Bergier on 2022/03/12.
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

private let backupDate = Date(timeIntervalSince1970: 0)

// This is a hack created to improve performance when there are
// thousands of items.
public struct FAST_Website: Identifiable, Hashable {
    
    private var model: CD_Website
    
    public var uuid: Website.Ident
    public var id: String         { self.uuid.id }
    public var preferredURL: URL? { self.resolvedURL ?? self.originalURL }
    
    public var isArchived: Bool   { self.model.cd_isArchived }
    public var originalURL: URL?  { self.model.cd_originalURL }
    public var resolvedURL: URL?  { self.model.cd_resolvedURL }
    public var title: String?     { self.model.cd_title }
    public var thumbnail: Data?   { self.model.cd_thumbnail }
    public var dateCreated: Date  { self.model.cd_dateCreated ?? backupDate }
    public var dateModified: Date { self.model.cd_dateModified ?? backupDate }
    
    internal init(_ model: CD_Website) {
        self.model = model
        self.uuid = .init(model.objectID)
    }
    
    public var websiteValue: Website { .init(self.model) }
}
