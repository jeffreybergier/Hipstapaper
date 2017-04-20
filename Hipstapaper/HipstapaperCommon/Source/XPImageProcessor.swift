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
    public static let maxFileSize: Int = 10240
    private static let startJPEGQuality: Int = 6
    
    #if os(OSX)
    public static func compressedJPEGImageData(fromAnyImageData data: Data) -> Data? {
        let _bmp = NSBitmapImageRep(data: data)
        guard let bmp = _bmp else { return nil }
        let data = self.compressedJPEGImageData(from: bmp)
        return data
    }
    
    public static func compressedJPEGImageData(from image: NSImage) -> Data? {
        var rect = NSRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        let _cgImage = image.cgImage(forProposedRect: &rect, context: nil, hints: nil)
        guard let cgImage = _cgImage else { return nil }
        let bmp = NSBitmapImageRep(cgImage: cgImage)
        let data = self.compressedJPEGImageData(from: bmp)
        return data
    }
    
    private static func compressedJPEGImageData(from bmp: NSBitmapImageRep) -> Data? {
        var data: Data?
        var quality = self.startJPEGQuality
        while data == nil && quality >= 0 {
            let jpegQuality = NSNumber(value: Float(quality) / 10)
            let newData = bmp.representation(using: NSBitmapImageFileType.JPEG, properties: [NSImageCompressionFactor : jpegQuality])
            if let newData = newData, newData.count <= self.maxFileSize {
                data = newData
            }
            quality -= 1
        }
        return data
    }
    #else
    public static func compressedJPEGImageData(fromAnyImageData data: Data) -> Data? {
        let _image = UIImage(data: data)
        guard let image = _image else { return nil }
        let data = self.compressedJPEGImageData(from: image)
        return data
    }
    public static func compressedJPEGImageData(from image: UIImage) -> Data? {
        var data: Data?
        var quality = self.startJPEGQuality
        while data == nil && quality >= 0 {
            let jpegQuality = CGFloat(quality) / 10
            print(jpegQuality)
            let newData = UIImageJPEGRepresentation(image, jpegQuality)
            if let newData = newData, newData.count <= self.maxFileSize {
                print(newData.count)
                data = newData
            }
            quality -= 1
        }
        return data
    }
    #endif
}


