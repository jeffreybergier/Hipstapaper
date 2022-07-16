//
//  Created by Jeffrey Bergier on 2022/07/10.
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

@propertyWrapper
public struct Controller: DynamicProperty {
    
    @EnvironmentObject private var env: BlackBox<ControllerProtocol?>
    
    public init() { }
    
    public var wrappedValue: ControllerProtocol {
        self.env.value!
    }
    
    internal var cd: CD_Controller {
        self.env.value as! CD_Controller
    }
}

extension Controller {
    public static func newEnvironment() -> BlackBox<ControllerProtocol?> {
        switch CD_Controller.new() {
        case .success(let controller):
            return BlackBox(controller)
        case .failure(let error):
            NSLog(String(describing: error))
            assertionFailure(String(describing: error))
            return BlackBox(nil)
        }
    }
}
