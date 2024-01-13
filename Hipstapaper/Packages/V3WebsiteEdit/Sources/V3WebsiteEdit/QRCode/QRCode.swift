//
//  Created by Jeffrey Bergier on 2024/01/13.
//
//  MIT License
//
//  Copyright (c) 2024 Jeffrey Bergier
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

import SwiftUI
import CoreGraphics

/// Code adapted from ChatGPT query
public func generateQRCode(from string: String, withSize size: CGFloat) throws -> Image {
    // Create a CIFilter object for generating QR codes
    guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else {
        fatalError("Create Error Type")
    }
    
    // Set the input message for the QR code
    let data = string.data(using: String.Encoding.ascii)
    qrFilter.setValue(data, forKey: "inputMessage")
    
    // Get the output image from the filter
    guard let outputImage = qrFilter.outputImage else {
        fatalError("Create Error Type")
    }
    
    // Create a transformation to scale the image to the desired size
    let scale = size / outputImage.extent.width
    let transformedImage = outputImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
    
    // Convert CIImage to UIImage
    let context = CIContext(options: nil)
    guard let cgImage = context.createCGImage(transformedImage, from: transformedImage.extent) else {
        fatalError("Create Error Type")
    }
    let qrCodeImage = Image(cgImage, scale: scale, label: Text(string))
    return qrCodeImage
}

