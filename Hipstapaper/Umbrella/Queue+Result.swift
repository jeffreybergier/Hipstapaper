//
//  Created by Jeffrey Bergier on 2021/02/18.
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

extension Queue {
    @discardableResult
    public mutating func append<Ignored>(_ result: Result<Ignored, Element>) -> Result<Ignored, Element>
    {
        guard case .failure(let element) = result else { return result }
        self.append(element)
        return result
    }
    @discardableResult
    public mutating func append<Ignored>(_ result: Result<Element, Ignored>) -> Result<Element, Ignored>
    {
        guard case .success(let element) = result else { return result }
        self.append(element)
        return result
    }
}
