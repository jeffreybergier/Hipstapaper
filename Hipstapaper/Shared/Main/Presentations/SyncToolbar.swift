//
//  Created by Jeffrey Bergier on 2021/01/29.
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
import Datum
import Stylize

extension STZ.TB {
    struct Sync: View {
        
        @ObservedObject var progress: AnyContinousProgress
        @EnvironmentObject private var errorQ: ErrorQueue
        
        init(_ progress: AnyContinousProgress) {
            _progress = .init(wrappedValue: progress)
        }
        
        @ViewBuilder var body: some View {
            if self.progress.isLoggedIn == false {
                STZ.TB.CloudAccountError.toolbar {
                    self.errorQ.queue.append(Error.cloudAccount)
                }
            } else if self.progress.errorQ.queue.isEmpty == false {
                STZ.TB.CloudSyncError.toolbar {
                    self.errorQ.queue.append(self.progress.errorQ.queue)
                }
            }
        }
    }
}
