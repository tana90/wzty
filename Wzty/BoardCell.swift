//
//  BoardCell.swift
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
//  Created by Tudor Ana on 17/01/2018.
//  Copyright © 2018 Tudor Ana. All rights reserved.
//

import UIKit

final class BoardCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    @IBOutlet weak var userImage1: UIImageView!
    @IBOutlet weak var userImage2: UIImageView!
    @IBOutlet weak var userImage3: UIImageView!
    @IBOutlet weak var userImage4: UIImageView!
    
    func show(_ board: Board?) {
        
        guard let boardT = board else { return }
        nameLabel?.text = boardT.name?.uppercased()
        
        userImage1.image = nil
        userImage2.image = nil
        userImage3.image = nil
        userImage4.image = nil
        
        userImage1.backgroundColor = .clear
        userImage2.backgroundColor = .clear
        userImage3.backgroundColor = .clear
        userImage4.backgroundColor = .clear
        
        let predicate = NSPredicate(format: "boardId == %@ AND following == true", boardT.objectId!)
        User.fetchAllBy(predicate: predicate) { [unowned self] (users) in
            guard let usersT = users else { return }
            
            self.countLabel.text = String(format: "%ld follows", usersT.count)
            
            for index in 0...usersT.count - 1 {
                if let imageUrl = usersT[index]?.userImageUrl {
                    if index == 0 {
                        userImage1.kf.setImage(with: URL(string: imageUrl))
                        userImage1.backgroundColor = .white
                    } else if index == 1 {
                        userImage2.kf.setImage(with: URL(string: imageUrl))
                        userImage2.backgroundColor = .white
                    } else if index == 2 {
                        userImage3.kf.setImage(with: URL(string: imageUrl))
                        userImage3.backgroundColor = .white
                    } else if index == 3 {
                        userImage4.kf.setImage(with: URL(string: imageUrl))
                        userImage4.backgroundColor = .white
                    }
                }
            }
        }
    }
}
