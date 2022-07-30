//
//  Created by Jeffrey Bergier on 2022/07/27.
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

#if DEBUG
extension Controller {
    public func createFakeData() -> Result<Void, Error> {
        let controller = self.wrappedValue as! CD_Controller
        let context = controller.context
        let _tags: [CD_Tag] = (0...20).map { idx in
            let tag = CD_Tag(context: context)
            tag.cd_name = UUID().uuidString
            return tag
        }
        let tags = Set(_tags)
        for idx in 0..<5_000 {
            let site = CD_Website(context: context)
            site.cd_title = UUID().uuidString
            site.cd_originalURL = URL(string: "https://www.theverge.com/" + UUID().uuidString)
            site.cd_resolvedURL = URL(string: "https://www.theverge.com/" + UUID().uuidString)
            site.cd_dateCreated = Date(timeIntervalSince1970: .random(in: -500_000_000...500_000_000))
            site.cd_dateModified = Date(timeIntervalSince1970: .random(in: -500_000_000...500_000_000))
            site.cd_isArchived = true
            site.addToCd_tags(tags.randomElement()!)
            site.addToCd_tags(tags.randomElement()!)
            site.addToCd_tags(tags.randomElement()!)
            if idx % 10 == 0 {
                site.cd_isArchived = false
            }
        }
        return context.datum_save()
    }
    
    public func deleteAllData() -> Result<Void, Error> {
        let controller = self.wrappedValue as! CD_Controller
        let context = controller.context
        
        let siteRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "CD_Website")
        let tagRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "CD_Tag")

        // Create a batch delete request for the
        // fetch request
        let sitesDelete = NSBatchDeleteRequest(fetchRequest: siteRequest)
        let tagsDelete = NSBatchDeleteRequest(fetchRequest: tagRequest)

        // Specify the result of the NSBatchDeleteRequest
        // should be the NSManagedObject IDs for the
        // deleted objects
        sitesDelete.resultType = .resultTypeObjectIDs
        tagsDelete.resultType = .resultTypeObjectIDs

        // Perform the batch delete
        let sitesDeleteResult = (try? context.execute(sitesDelete) as? NSBatchDeleteResult)?.result as? [NSManagedObjectID] ?? []
        let tagsDeleteResult = (try? context.execute(tagsDelete) as? NSBatchDeleteResult)?.result as? [NSManagedObjectID] ?? []
        
        guard sitesDeleteResult.isEmpty == false
           && tagsDeleteResult.isEmpty == false
        else { return .success(()) }
        
        NSManagedObjectContext.mergeChanges(
            fromRemoteContextSave: [
                NSDeletedObjectsKey: sitesDeleteResult + tagsDeleteResult
            ],
            into: [context]
        )
        
        return .success(())
    }
}
#endif

