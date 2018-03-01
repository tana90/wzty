//
//  File.swift
//  Wzty
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
//  Created by Tudor Ana on 2/26/18.
//  Copyright © 2018 Tudor Ana. All rights reserved.
//

import UIKit

final class TrendCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel?
    
    func show(_ trend: Trend?) {
        guard let _ = trend else { return }
        nameLabel?.text = trend!.name
    }
}
