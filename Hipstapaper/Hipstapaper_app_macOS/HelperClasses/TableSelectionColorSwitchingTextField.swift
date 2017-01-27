//
//  LabelColorSwitchingTableCellView.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 1/26/17.
//  Copyright © 2017 Jeffrey Bergier. All rights reserved.
//

import AppKit

// The purpose of this is to change color when the selection changes on the tableview. There are some hacks in here.
// Normally NSTableCellView forwards the setBackgroundStyle message to all subviews.
// However, it doesn't do this recursiely.
// Since the labels are wthin a stackview they don't get the message.
// Below there is an extension stackview that forwards this message on to my special label.

class TableSelectionColorSwitchingTextField: NSTextField {
    var backgroundStyle: NSBackgroundStyle {
        set {
            switch newValue {
            case .dark:
                self.textColor = NSColor.white
            case .light:
                self.textColor = NSColor.labelColor
            case .lowered, .raised:
                fatalError()
            }
        }
        get { fatalError() } // swift does not allow set only properties
    }
}

extension NSStackView {
    var backgroundStyle: NSBackgroundStyle {
        set {
            for view in self.views {
                if let view = view as? NSStackView {
                    view.backgroundStyle = newValue
                } else if let view = view as? TableSelectionColorSwitchingTextField {
                    view.backgroundStyle = newValue
                } else {
                    continue
                }
            }
        }
        get { fatalError() }
    }
}

//extension NSBackgroundStyle: CustomStringConvertible {
//    public var description: String {
//        switch self {
//        case .dark:
//            return ".dark"
//        case .light:
//            return ".light"
//        case .lowered:
//            return ".lowered"
//        case .raised:
//            return ".raised"
//        }
//    }
//}
