//
//  Created by Jeffrey Bergier on 2020/11/24.
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

@objc(CD_Tag) internal class CD_Tag: CD_Base {

    internal static let defaultSort: SortDescriptor<CD_Tag> = .init(\.cd_name, comparator: .localizedStandard)
    
    internal class override var entityName: String { "CD_Tag" }
    internal class var request: NSFetchRequest<CD_Tag> {
        NSFetchRequest<CD_Tag>(entityName: self.entityName)
    }
    
    override func willSave() {
        super.willSave()
        let newWebsitesCount = Int32(self.cd_websites?.count ?? 0)
        if self.cd_websitesCount != newWebsitesCount {
            self.cd_websitesCount = newWebsitesCount
        }
        
        // Validate Title
        if let name = self.cd_name, name.trimmed == nil {
            self.cd_name = nil
        }
    }
}

extension Tag {
    internal init(_ cd: CD_Tag) {
        self.init(id: .init(cd.objectID),
                  name: cd.cd_name,
                  websitesCount: Int(cd.cd_websitesCount),
                  dateCreated: cd.cd_dateCreated,
                  dateModified: cd.cd_dateModified)
    }
}
