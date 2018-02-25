//
//  UserInfoViewController.swift
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
//  Created by Tudor Ana on 2/15/18.
//  Copyright © 2018 Tudor Ana. All rights reserved.
//

import UIKit

final class UserInfoViewController: BaseTableViewController {
    
    @IBOutlet private weak var userImageView: UIImageView!
    @IBOutlet private weak var userFullNameLabel: UILabel!
    @IBOutlet private weak var userNameLabel: UILabel!
    @IBOutlet private weak var followingsCountLabel: UILabel!
    @IBOutlet private weak var locationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        User.current { [unowned self] (user) in
            guard let _ = user else {
                self.navigationController?.popViewController(animated: true)
                return
            }
            self.updateInfo(for: user)
            
            //Force reload current user info
            User.current(refreshable: true) { [weak self] (user) in
                guard let _ = self else { return }
                self!.updateInfo(for: user)
            }
        }
    }
    
    func updateInfo(for user: User) {
        
        //User image
        if let imageUrlT = user.userImageUrl {
            userImageView?.kf.setImage(with: URL(string: imageUrlT))
        } else {
            userImageView?.image = nil
        }
        
        //Name
        userFullNameLabel?.text = user.name
        
        //Username
        userNameLabel?.text = String(format: "@%@", user.username!)
        
        //Followings count
        followingsCountLabel.text = String(format: "%ld", (user.followingsCount?.intValue)!)
        
        if let _ = user.location,
            (user.location)!.count > 0 {
            locationLabel.text = user.location!
        }
    }
}
