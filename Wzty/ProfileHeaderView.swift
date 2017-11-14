//
//  ProfileHeaderView.swift
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
//  Created by Tudor Ana on 04/11/2017.
//

import UIKit

final class ProfileHeaderView: UIView {

    @IBOutlet weak var bannerImageView: UIImageView?
    @IBOutlet weak var gradientView: UIView?
    @IBOutlet weak var userImageView: UIImageView?
    @IBOutlet weak var usernameLabel: UILabel?
    public var settingsActionHandler: (()->Void)?
    
    
    @IBAction func settingsAction() {
        if let handler = settingsActionHandler {
            handler()
        }
    }
    
    func show(_ user: User?) {
        
        guard let userT = user else { return }
        
        //Draw a gradient 
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = (self.gradientView?.bounds)!
        gradientLayer.colors = [UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor, UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.0).cgColor]
        self.gradientView?.layer.addSublayer(gradientLayer)
     
        //User image
        if let imageUrlT = userT.userImageUrl {
            userImageView?.kf.setImage(with: URL(string: imageUrlT))
        } else {
            userImageView?.image = nil
        }
        
        //Username
        usernameLabel?.text = userT.name

    }
    
}
