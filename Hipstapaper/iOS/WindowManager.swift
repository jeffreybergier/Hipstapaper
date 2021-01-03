//
//  Created by Jeffrey Bergier on 2020/12/29.
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

import UIKit
import Combine

class WindowManager: ObservableObject, WindowManagerProtocol {
    
    private var app: UIApplication { UIApplication.shared }
    
    var features: Features {
        var features: Features = []
        if self.app.supportsMultipleScenes {
            features.insert(.multipleWindows)
        }
        return features
    }
    
    func show(_ urls: Set<URL>, error errorHandler: @escaping (Error) -> Void) {
        guard self.features.contains(.multipleWindows) else { errorHandler(.unsupported); return }
        guard urls.count <= 1 else { errorHandler(.bulkActivation); return }
        guard let url = urls.first else { return }
        let activity = NSUserActivity(activityType: "Browser")
        activity.referrerURL = url
        self.app.requestSceneSessionActivation(nil,
                                               userActivity: activity,
                                               options: nil)
        { error in
            errorHandler(.activation(error))
        }
    }
}
