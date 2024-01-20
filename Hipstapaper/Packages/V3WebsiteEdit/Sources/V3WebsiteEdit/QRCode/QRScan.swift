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

internal struct QRScan: View {
    
    @Binding private var url: URL?
    
    internal init(_ url: Binding<URL?>?) {
        _url = url ?? .constant(nil)
    }
    
    internal var body: some View {
        #if canImport(UIKit)
        _QRScan(self.$url)
        #else
        Text("Not Supported")
        #endif
    }
}

#if canImport(UIKit)
import QRScanner

fileprivate struct _QRScan: View {
    
    @Environment(\.dismiss) private var dismiss
    @Binding private var url: URL?
    
    internal init(_ url: Binding<URL?>) {
        _url = url
    }
    
    private func update(_ qr: QRScannerView, context: Context) {
        
    }
    
    private func makeScanView(context: Context) -> QRScannerView {
        let qr = QRScannerView(frame: .init(x: 0, y: 0, width: 320, height: 320))
        qr.configure(delegate: context.coordinator, input: .default)
        qr.startRunning()
        return qr
    }
    
    internal func makeCoordinator() -> QRScannerViewDelegate {
        return Delegate { scannedString in
            self.url = scannedString.map { URL(string: $0) } ?? nil
            self.dismiss()
        }
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
    
    private let onComplete: (String?) -> Void
    
    fileprivate init(onComplete: @escaping (String?) -> Void) {
        self.onComplete = onComplete
    }
    
    func qrScannerView(_ qrScannerView: QRScannerView, didFailure error: QRScannerError) {
        print(String(describing: error))
        assertionFailure()
        self.onComplete(nil)
    }
    func qrScannerView(_ qrScannerView: QRScannerView, didSuccess code: String) {
        self.onComplete(code)
    }
    func qrScannerView(_ qrScannerView: QRScannerView, didChangeTorchActive isOn: Bool) {
        print(isOn)
    }
}
#endif
