//
//  Created by Jeffrey Bergier on 2021/01/09.
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

import WebKit

public struct ThumbnailConfiguration {
    public var compressionFactor: CGFloat = 0.4
    // TODO: Centralize max thumbnail size
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
