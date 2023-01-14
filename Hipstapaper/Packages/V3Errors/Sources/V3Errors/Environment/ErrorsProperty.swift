//
//  Created by Jeffrey Bergier on 2022/08/23.
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
import Collections
import Umbrella


@propertyWrapper
@available(*, deprecated, message:"Use `@Umbrella.ErrorStorage`")
public struct Errors: DynamicProperty {
    
    public typealias Value = Deque<CodableError>
    public typealias ExtensionEnvironment = ObserveBox<Value>
    
    /// Needed when `\.sceneContext` environment value is set to extension / other
    public static func newEnvironment() -> ExtensionEnvironment { .init(.init()) }
    
    @JSBAppStorage  ("com.hipstapaper.errors.normal") private var normal = Value()
    @JSBSceneStorage("com.hipstapaper.errors.scene")  private var scene: [String: Value] = [:]
    @EnvironmentObject private var ext: ExtensionEnvironment
    
    @Environment(\.sceneContext) private var context
    
    public init() { }
    
    public var wrappedValue: Value {
        get {
            switch self.context {
            case .normal:
                return self.normal
            case .scene(let id):
                return self.scene[id] ?? .init()
            case .extensionKeyboard,
                    .extensionShare,
                    .extensionWidget,
                    .other:
                return self.ext.value
            }
        }
        nonmutating set {
            switch self.context {
            case .normal:
                self.normal = newValue
            case .scene(let id):
                self.scene[id] = newValue
            case .extensionKeyboard,
                    .extensionShare,
                    .extensionWidget,
                    .other:
                self.ext.value = newValue
            }
        }
    }
    
    public var projectedValue: Binding<Value> {
        Binding {
            self.wrappedValue
        } set: {
            self.wrappedValue = $0
        }
    }
}
