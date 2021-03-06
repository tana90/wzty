//
//  SelectedUserCollectionViewCell.swift
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
//  Created by Tudor Ana on 2/22/18.
//  Copyright © 2018 Tudor Ana. All rights reserved.
//

import UIKit

final class SelectedUserCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var userImageView: UIImageView?
    @IBOutlet weak var nameLabel: UILabel?
    
    func show(_ user: User?) {
        
        guard let _ = user else { return }
        
        //User image
        if let imageUrlT = user!.userImageUrl {
            userImageView?.kf.setImage(with: URL(string: imageUrlT))
        } else {
            userImageView?.image = nil
        }
        
        //Name
        nameLabel?.text = user!.name
    }
}
