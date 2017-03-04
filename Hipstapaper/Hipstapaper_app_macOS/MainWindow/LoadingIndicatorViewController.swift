//
//  LoadingIndicatorViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 2/2/17.
//  Copyright © 2017 Jeffrey Bergier. All rights reserved.
//

import Common
import Aspects

// swiftlint:disable:next type_name
class AppearanceObservingLoadingIndicatorViewController: LoadingIndicatorViewController {
    
    private lazy var appearanceObserver: KeyValueObserver<NSAppearance> = KeyValueObserver(target: self.view.window!, keyPath: #keyPath(NSWindow.appearance))
    private var aspectToken: AspectToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewDidMoveToWindowClosure: @convention(block) (Void) -> Void = { [weak self] in
            guard let _ = self?.view.window else { return }
            // update the appearance immeditately
            self?.updateAppearance()
            // also start observing for changes
            self?.appearanceObserver.startObserving() { _ -> NSAppearance? in
                self?.updateAppearance()
                return nil
            }
        }
        
        self.aspectToken = try? self.view.aspect_hook(#selector(self.view.viewDidMoveToWindow), with: [], usingBlock: viewDidMoveToWindowClosure)
    }
    
    private func updateAppearance() {
        if
            let appearance = self.view.window?.appearance,
            AppleInterfaceStyleWindowAppearanceSwitcher.Style(appearance: appearance) == .dark
        {
            // if we have a valid appearance and that appearance is dark, set the background color accordingly.
            self.setBackgroundColor(NSColor.windowBackgroundColor)
        } else {
            // icon color is the default
            // unless we have a valid appearance and that appearance is dark, we want to set it to icon color
            self.setBackgroundColor(Color.iconColor)
        }
    }
    
    deinit {
        self.aspectToken?.remove()
    }
    
}
