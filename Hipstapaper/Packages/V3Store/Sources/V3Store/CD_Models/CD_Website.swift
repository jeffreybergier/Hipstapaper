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
import V3Model

@objc(CD_Website) internal class CD_Website: CD_Base {

    internal class override var entityName: String { "CD_Website" }
    internal class var request: NSFetchRequest<CD_Website> {
        NSFetchRequest<CD_Website>(entityName: self.entityName)
    }
    
    override func willSave() {
        super.willSave()
        
        // Validate Title
        if let title = self.cd_title, title.trimmed == nil {
            self.cd_title = nil
        }

        // Validate Thumbnail Size
        if let thumb = self.cd_thumbnail, thumb.count > Website.maxSize {
            self.cd_thumbnail = nil
        }
    }
}

extension Website {
    internal init(_ cd: CD_Website) {
        self.init(id: .init(cd.objectID),
                  isArchived: cd.cd_isArchived,
                  originalURL: cd.cd_originalURL,
                  resolvedURL: cd.cd_resolvedURL,
                  title: cd.cd_title,
                  thumbnail: cd.cd_thumbnail,
                  dateCreated: cd.cd_dateCreated,
                  dateModified: cd.cd_dateModified)
    }
}
