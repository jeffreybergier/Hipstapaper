//
//  Created by Jeffrey Bergier on 2020/12/22.
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

import SwiftUI
import Umbrella
import Localize
import Collections

extension STZ {
    public struct SHR: View {
        
        public enum Error: UserFacingError {
            public var errorCode: Int               { 1001 }
            public var message: String  { "// TODO: Fix this" } // Phrase.errorShareItemCount.rawValue }
            case itemCount
        }
        
        public typealias Completion = () -> Void
        
        private let items: [URL]
        private let completion: Completion
        
        @ErrorQueue private var errorQ
        @Environment(\.presentationMode) private var presentationMode
        
        public var body: some View {
            Bridge(items: self.items, completion: self.completion)
                .frame(width: self.forcedFrame, height: self.forcedFrame)
                // .modifier(ErrorQueuePresenter()) TODO: Fix error presentation
                // .environmentObject(self.errorQ)
                .onAppear {
                    guard self.items.isEmpty else { return }
                    self.errorQ.append(Error.itemCount)
                }
        }
        
        public init(items: [URL], completion: @escaping SHR.Completion) {
            self.items = items
            self.completion = completion
        }
        
        private var forcedFrame: CGFloat? {
            #if os(macOS)
            return 10
            #else
            return nil
            #endif
        }
    }
}

extension STZ.SHR {
    fileprivate struct Bridge: View {
        let items: [URL]
        let completion: Completion
    }
}

#if os(macOS)
import AppKit
extension STZ.SHR.Bridge: NSViewRepresentable {
    func updateNSView(_ view: NSView, context: Context) {
        guard context.coordinator.alreadyPresented == false else { return }
        context.coordinator.alreadyPresented = true
        let picker = NSSharingServicePicker(items: self.items)
        picker.delegate = context.coordinator
        // This must be presented async so the view has time to enter the window
        // *** Assertion failure in -[NSMenu popUpMenuPositioningItem:atLocation:inView:appearance:],
        // NSMenu.m:1651 View is not in any window
        DispatchQueue.main.async {
            picker.show(relativeTo: .zero, of: view, preferredEdge: .minY)
        }
    }
    func makeNSView(context: Context) -> NSView { return NSView() }
    func makeCoordinator() -> Delegate { return Delegate(completion: self.completion) }
    fileprivate class Delegate: NSObject, NSSharingServicePickerDelegate {
        let completion: STZ.SHR.Completion
        var alreadyPresented = false
        init(completion: @escaping STZ.SHR.Completion) { self.completion = completion }
        @objc func sharingServicePicker(_ sharingServicePicker: NSSharingServicePicker,
                                        didChoose service: NSSharingService?)
        {
            self.completion()
            sharingServicePicker.delegate = nil
        }
    }
}
#else
import UIKit
extension STZ.SHR.Bridge: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let vc = UIActivityViewController(activityItems: self.items, applicationActivities: nil)
        vc.completionWithItemsHandler = { _, _, _, _ in
            completion()
        }
        return vc
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) { }
}
#endif

#if DEBUG
struct Share_Preview: PreviewProvider {
    static var items = [URL(string: "https://www.google.com")!]
    static var previews: some View {
        STZ.SHR(items: items, completion: { })
    }
}
#endif
