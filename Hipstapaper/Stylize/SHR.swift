//
//  Created by Jeffrey Bergier on 2020/12/22.
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

import SwiftUI
import Umbrella
import Localize

extension STZ {
    public struct SHR: View {
        
        public enum Error: UserFacingError {
            public static var errorDomain: String = "com.saturdayapps.Hipstapaper.Stylize.Share"
            public var errorCode: Int               { 1001 }
            public var message: LocalizedStringKey  { Phrase.errorShareItemCount.rawValue }
            case itemCount
        }
        
        public typealias Completion = () -> Void
        
        private let items: [URL]
        private let completion: Completion
        
        @StateObject private var errorQ = ErrorQueue()
        @Environment(\.presentationMode) private var presentationMode
        
        public var body: some View {
            Bridge(items: self.items, completion: self.completion)
                .frame(width: self.forcedFrame, height: self.forcedFrame)
                .modifier(ErrorQueuePresenter())
                .environmentObject(self.errorQ)
                .onAppear() {
                    guard self.items.isEmpty else { return }
                    self.errorQ.queue.append(Error.itemCount)
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
