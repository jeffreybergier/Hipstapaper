//
//  Created by Jeffrey Bergier on 2021/01/09.
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

import WebKit

public struct ThumbnailConfiguration {
    public var compressionFactor: CGFloat = 0.4
    public var maxThumbSize: Int = 100_000
    public var snapConfig: WKSnapshotConfiguration = {
        let config = WKSnapshotConfiguration()
        config.afterScreenUpdates = true
        config.snapshotWidth = NSNumber(value: 300.0)
        return config
    }()
}

#if canImport(AppKit)

import AppKit

extension WKWebView {
    internal func snap_takeSnapshot(with config: ThumbnailConfiguration,
                                    completion: @escaping (Result<Data, Error>) -> Void)
    {
        self.takeSnapshot(with: config.snapConfig) { image, error in
            if let error = error {
                completion(.failure(.take(error)))
                return
            }
            guard
                let tiff = image?.tiffRepresentation,
                let rep = NSBitmapImageRep(data: tiff),
                let data = rep.representation(using: NSBitmapImageRep.FileType.jpeg,
                                              properties: [.compressionFactor: config.compressionFactor])
            else {
                completion(.failure(.convertImage))
                return
            }
            guard data.count <= config.maxThumbSize else {
                completion(.failure(.size(data.count)))
                return
            }
            completion(.success(data))
        }
    }
}

#endif

#if canImport(UIKit)

import UIKit

extension WKWebView {
    internal func snap_takeSnapshot(with config: ThumbnailConfiguration,
                                    completion: @escaping (Result<Data, Error>) -> Void)
    {
        self.takeSnapshot(with: config.snapConfig) { image, error in
            if let error = error {
                completion(.failure(.take(error)))
                return
            }
            // TODO: Convert this to JPEG Compression
            guard let data = image?.jpegData(compressionQuality: config.compressionFactor) else {
                completion(.failure(.convertImage))
                return
            }
            guard data.count <= config.maxThumbSize else {
                completion(.failure(.size(data.count)))
                return
            }
            completion(.success(data))
        }
    }
}

#endif
