//
//  Created by Jeffrey Bergier on 2020/12/13.
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

extension View {
    
    internal func paddingToolbar(ignoring sides: EdgeInsets.Sides = []) -> some View {
        var insets = EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
        insets.remove(sides)
        return self.padding(insets)
    }
    
    internal func paddingNumberOval(ignoring sides: EdgeInsets.Sides = []) -> some View {
        var insets = EdgeInsets(top: 3, leading: 8, bottom: 3, trailing: 8)
        insets.remove(sides)
        return self.padding(insets)
    }
    
    public func paddingDefault(ignoring sides: EdgeInsets.Sides = []) -> some View {
        var insets = EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12)
        insets.remove(sides)
        return self.padding(insets)
    }
    
    public func paddingDefault_Equal(ignoring sides: EdgeInsets.Sides = []) -> some View {
        var insets = EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
        insets.remove(sides)
        return self.padding(insets)
    }
}

extension EdgeInsets {
    public typealias Side = WritableKeyPath<EdgeInsets, CGFloat>
    public typealias Sides = Set<Side>
    
    mutating internal func remove(_ sides: Sides) {
        for side in sides {
            self[keyPath: side] = 0
        }
    }
}
