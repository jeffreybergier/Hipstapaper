//
//  Created by Jeffrey Bergier on 2022/06/28.
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
internal struct Nav: DynamicProperty {
    
    @AppStorage("com.hipstapaper.nav") private var app: String?
    @SceneStorage("com.hipstapaper.nav") private var scene: String?
    
    var wrappedValue: Navigation {
        get {
            .init(scene: self.scene?.decodeSceneNav,
                  app: self.app?.decodeAppNav)
        }
        nonmutating set {
            self.app = newValue.appValue.encodeString
            self.scene = newValue.sceneValue.encodeString
        }
    }
    
    var projectedValue: Binding<Navigation> {
        Binding {
            self.wrappedValue
        } set: {
            self.wrappedValue = $0
        }
    }
    
}

extension Navigation {
    fileprivate init(scene: SceneStorageNavigation?, app: AppStorageNavigation?) {
        self.sidebar = scene?.sidebar ?? .init()
        self.detail = scene?.detail ?? .init()
        self.isError = scene?.isError
        self.errorQueue = app?.errorQueue ?? []
    }
    
    fileprivate var appValue: AppStorageNavigation {
        .init(errorQueue: self.errorQueue)
    }
    fileprivate var sceneValue: SceneStorageNavigation {
        .init(sidebar: self.sidebar,
              detail: self.detail,
              isError: self.isError)
    }
}

fileprivate struct SceneStorageNavigation: Codable {
    fileprivate var sidebar: Navigation.Sidebar
    fileprivate var detail: Navigation.Detail
    fileprivate var isError: CodableError?
}

fileprivate struct AppStorageNavigation: Codable {
    fileprivate var errorQueue: Deque<CodableError>
}

extension String {
    fileprivate var decodeSceneNav: SceneStorageNavigation? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return try? PropertyListDecoder().decode(SceneStorageNavigation.self, from: data)
    }
    fileprivate var decodeAppNav: AppStorageNavigation? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return try? PropertyListDecoder().decode(AppStorageNavigation.self, from: data)
    }
}

extension SceneStorageNavigation {
    fileprivate var encodeString: String? {
        guard let data = try? PropertyListEncoder().encode(self) else { return nil }
        return data.base64EncodedString()
    }
}

extension AppStorageNavigation {
    fileprivate var encodeString: String? {
        guard let data = try? PropertyListEncoder().encode(self) else { return nil }
        return data.base64EncodedString()
    }
}
