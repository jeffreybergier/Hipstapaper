//
//  URLItemCocoaTouch.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/20/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import UIKit

extension URLItem {
    var image: UIImage? {
        get {
            guard let data = self.imageData else { return .none }
            let image = UIImage(data: data)
            return image
        }
        set {
            guard let image = newValue else { self.imageData = .none; return }
            let data = UIImagePNGRepresentation(image)
            self.imageData = data
            self.modificationDate = Date()
        }
    }
}
