//
//  XPImageProcessor.swift
//  Pods
//
//  Created by Jeffrey Bergier on 4/19/17.
//
//

#if os(OSX)
    import AppKit
#else
    import UIKit
#endif

public struct XPImageProcessor {
    
    public static let maxDimensionSize: Int = 260
    public static let maxFileSize: Int = 15000
    private static let startJPEGQuality: Int = 6
    
    #if os(OSX)
    public static func compressedJPEGImageData(fromAnyImageData data: Data) -> Data? {
        // bail out early if the data is already small enough
        guard data.count > self.maxFileSize else { return data }
        guard let bmp = NSBitmapImageRep(data: data) else { return nil }
        let data = self.compressedJPEGImageData(from: bmp)
        return data
    }
    
    public static func compressedJPEGImageData(from inputImage: NSImage) -> Data? {
        let image = inputImage
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
        let bmp = NSBitmapImageRep(cgImage: cgImage)
        let data = self.compressedJPEGImageData(from: bmp)
        return data
    }
    
    private static func compressedJPEGImageData(from bmp: NSBitmapImageRep) -> Data? {
        let size = NSSize(width: self.maxDimensionSize, height: self.maxDimensionSize)
        if bmp.size.width > size.width || bmp.size.height > size.height {
            bmp.size = size
        }
        var data: Data?
        var quality = self.startJPEGQuality
        while data == nil && quality >= 0 {
            let jpegQuality = NSNumber(value: Float(quality) / 10)
            let newData = bmp.representation(using: .jpeg, properties: [.compressionFactor: jpegQuality])
            if let newData = newData, newData.count <= self.maxFileSize {
                data = newData
                break
            }
            quality -= 1
        }
        return data
    }
    #else
    public static func compressedJPEGImageData(fromAnyImageData data: Data) -> Data? {
        // bail out early if the data is already small enough
        guard data.count > self.maxFileSize else { return data }
        guard let image = UIImage(data: data) else { return nil }
        let data = self.compressedJPEGImageData(from: image)
        return data
    }
    public static func compressedJPEGImageData(from inputImage: UIImage) -> Data? {
        let image: UIImage
        let size = CGSize(width: self.maxDimensionSize, height: self.maxDimensionSize)
        if inputImage.size.width > size.width || inputImage.size.height > size.height {
            UIGraphicsBeginImageContext(size)
            inputImage.draw(in: CGRect(origin: CGPoint.zero, size: size))
            guard let scaledImage = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
            UIGraphicsEndImageContext()
            image = scaledImage
        } else {
            image = inputImage
        }
        var data: Data?
        var quality = self.startJPEGQuality
        while data == nil && quality >= 0 {
            let jpegQuality = CGFloat(quality) / 10
            let newData = UIImageJPEGRepresentation(image, jpegQuality)
            if let newData = newData, newData.count <= self.maxFileSize {
                data = newData
                break
            }
            quality -= 1
        }
        return data
    }
    #endif
}
