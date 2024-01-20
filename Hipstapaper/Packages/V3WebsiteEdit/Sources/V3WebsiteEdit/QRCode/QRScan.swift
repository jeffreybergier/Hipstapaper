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
import QRScanner

#if canImport(UIKit)
internal struct QRScan: View {
    internal var body: some View {
        _QRScan()
    }
}

fileprivate struct _QRScan: View {
    
    private func update(_ qr: QRScannerView, context: Context) {
        qr.startRunning()
    }
    
    private func makeScanView(context: Context) -> QRScannerView {
        let qrScannerView = QRScannerView(frame: .zero)
        qrScannerView.configure(delegate: context.coordinator, input: .init(isBlurEffectEnabled: true))
        return qrScannerView
    }
    
    internal func makeCoordinator() -> QRScannerViewDelegate {
        fatalError()
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
#endif
