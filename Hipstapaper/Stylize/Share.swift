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

public struct Share: View {
    public typealias Completion = () -> Void
    public let items: [URL]
    public let completion: Completion
    public var body: some View {
        _Share(items: self.items, completion: self.completion)
            .frame(width: 10, height: 10)
    }
    public init(_ items: [URL], completion: @escaping Share.Completion) {
        self.items = items
        self.completion = completion
    }
}

internal struct _Share: View {
    let items: [URL]
    let completion: Share.Completion
}

#if canImport(AppKit)
import AppKit
extension _Share: NSViewRepresentable {
    
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
    
    func makeNSView(context: Context) -> NSView {
        return NSView()
    }
    
    func makeCoordinator() -> Delegate {
        return Delegate(completion: self.completion)
    }
    
    internal class Delegate: NSObject, NSSharingServicePickerDelegate {
        let completion: Share.Completion
        var alreadyPresented = false
        init(completion: @escaping Share.Completion) { self.completion = completion }
        @objc func sharingServicePicker(_ sharingServicePicker: NSSharingServicePicker,
                                        didChoose service: NSSharingService?)
        {
            self.completion()
            sharingServicePicker.delegate = nil
        }
    }
}

#if DEBUG
struct Share_Preview: PreviewProvider {
    
    static var items = [URL(string: "https://www.google.com")!]
    
    static var previews: some View {
        Share(items, completion: { })
    }
}
#endif

#endif
