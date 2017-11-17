//
//  UserProfileViewController.swift
//  Wzty
//
//  Created by Tudor Ana on 17/11/2017.
//  Copyright © 2017 Tudor Ana. All rights reserved.
//

import UIKit

final class UserProfileViewController: BaseProfileDetailsViewController {
    
}

extension UserProfileViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //User cell
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "userDetailsCell") as! UserDetailsCell
            return cell
        }
        
        return UITableViewCell()
        //Posts cells
    }
}
