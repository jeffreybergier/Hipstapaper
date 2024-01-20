//
//  Created by Jeffrey Bergier on 2024/01/20.
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
import V3Style

internal struct QRScan: View {
    
    internal typealias OnComplete = (Result<String, Error>) -> Void
    
    private let onComplete: OnComplete
    
    internal init(_ onComplete: @escaping OnComplete) {
        self.onComplete = onComplete
    }
    
    internal var body: some View {
        // TODO: Check for permission
        #if canImport(QRScanner)
        _QRScan(self.onComplete)
        #else
        Text("Not Supported")
        #endif
    }
}

#if canImport(QRScanner)
import QRScanner

fileprivate struct _QRScan: View {
    
    @V3Style.WebsiteEdit private var style
    private let onComplete: QRScan.OnComplete
    
    fileprivate init(_ onComplete: @escaping QRScan.OnComplete) {
        self.onComplete = onComplete
    }
    
    private func update(_ qr: QRScannerView, context: Context) { }
    
    private func makeScanView(context: Context) -> QRScannerView {
        let frame = CGRect(x: 0, y: 0,
                           width: self.style.viewSizeQRScan,
                           height: self.style.viewSizeQRScan)
        let qr = QRScannerView(frame: frame)
        qr.configure(delegate: context.coordinator, input: .default)
        qr.startRunning()
        return qr
    }
    
    internal func makeCoordinator() -> QRScannerViewDelegate {
        return Delegate(self.onComplete)
    }
}

extension _QRScan: UIViewRepresentable {
    func makeUIView(context: Context) -> QRScannerView {
        return self.makeScanView(context: context)
    }
    
    func updateUIView(_ wv: QRScannerView, context: Context) {
        self.update(wv, context: context)
    }
}

fileprivate class Delegate: QRScannerViewDelegate {
    
    private let onComplete: QRScan.OnComplete
    
    fileprivate init(_ onComplete: @escaping QRScan.OnComplete) {
        self.onComplete = onComplete
    }
    
    func qrScannerView(_ qrScannerView: QRScannerView, didFailure error: QRScannerError) {
        print(String(describing: error))
        assertionFailure()
        self.onComplete(.failure(error))
    }
    func qrScannerView(_ qrScannerView: QRScannerView, didSuccess code: String) {
        self.onComplete(.success(code))
    }
    func qrScannerView(_ qrScannerView: QRScannerView, didChangeTorchActive isOn: Bool) {
        print(isOn)
    }
}
#endif
