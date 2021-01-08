//
//  Created by Jeffrey Bergier on 2021/01/08.
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

import Foundation
import MobileCoreServices

extension NSExtensionItem {
    public func urlValue(completion: @escaping (URL?) -> Void) {
        let contentType = kUTTypeURL as String
        let urlAttachments = self.attachments?.filter {
            $0.hasItemConformingToTypeIdentifier(contentType)
        }
        guard let attachment = urlAttachments?.first else {
            completion(nil)
            return
        }
        attachment.loadItem(forTypeIdentifier: contentType, options: nil) { url, _ in
            DispatchQueue.main.async {
                guard let url = url as? URL else {
                    completion(nil)
                    return
                }
                completion(url)
            }
        }
    }
}
