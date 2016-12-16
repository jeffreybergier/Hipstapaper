//
//  FrameworkExtensions.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/9/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import UIKit

protocol ViewControllerPresenterDelegate: class {
    func presented(viewController: UIViewController, didDisappearAnimated: Bool)
}
