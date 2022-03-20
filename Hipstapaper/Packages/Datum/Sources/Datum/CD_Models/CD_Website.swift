//
//  Created by Jeffrey Bergier on 2020/11/23.
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

import CoreData

@objc(CD_Website) internal class CD_Website: CD_Base {

    internal class override var entityName: String { "CD_Website" }
    internal class var request: NSFetchRequest<CD_Website> {
        NSFetchRequest<CD_Website>(entityName: self.entityName)
    }

    @NSManaged internal var cd_isArchived:  Bool
    @NSManaged internal var cd_originalURL: URL?
    @NSManaged internal var cd_resolvedURL: URL?
    @NSManaged internal var cd_title:       String?
    @NSManaged internal var cd_thumbnail:   Data?
    @NSManaged internal var cd_tags:        NSSet
    
    override func willSave() {
        super.willSave()
        
        // Validate Title
        if let title = self.cd_title, title.trimmed == nil {
            self.cd_title = nil
        }

        // Validate Thumbnail Size
        // TODO: Centralize max thumbnail size
        if let thumb = self.cd_thumbnail, thumb.count > 100_000 {
            self.cd_thumbnail = nil
        }
    }
}

extension Website {
    internal init(_ cd: CD_Website) {
        self.dateCreated = cd.cd_dateCreated ?? Date.init(timeIntervalSince1970: 0)
        self.dateModified = cd.cd_dateModified ?? Date.init(timeIntervalSince1970: 0)
        self.uuid = .init(cd.objectID)
        
        self.isArchived = cd.cd_isArchived
        self.originalURL = cd.cd_originalURL
        self.resolvedURL = cd.cd_resolvedURL
        self.title = cd.cd_title
        self.thumbnail = cd.cd_thumbnail
    }
}
