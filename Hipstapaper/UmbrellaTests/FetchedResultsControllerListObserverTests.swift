//
//  Created by Jeffrey Bergier on 2021/02/22.
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

import XCTest
@testable import Umbrella

class FetchedResultsControllerListObserverTests: AsyncTestCase {
    
    func test_controllerWillChangePublisher() {
        let controller = FetchedResultsControllerListObserver(__TESTING: true)
        let wait = self.newWait()
        controller.objectWillChange.sink { _ in
            wait(nil)
        }.store(in: &self.tokens)
        controller.perform(#selector(NSFetchedResultsControllerDelegate.controllerWillChangeContent(_:)), with: nil)
        self.wait(for: .short)
     }
    
    func test_controllerDidChangePublisher() {
        let controller = FetchedResultsControllerListObserver(__TESTING: true)
        let wait = self.newWait()
        controller.__objectDidChange.sink { _ in
            wait(nil)
        }.store(in: &self.tokens)
        controller.perform(#selector(NSFetchedResultsControllerDelegate.controllerDidChangeContent(_:)), with: nil)
        self.wait(for: .short)
     }
    
}
