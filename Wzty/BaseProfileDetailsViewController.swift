//
//  BaseProfileDetailsViewController.swift
//  Wzty
//
//  Created by Tudor Ana on 17/11/2017.
//  Copyright © 2017 Tudor Ana. All rights reserved.
//

import UIKit

class BaseProfileDetailsViewController: BaseCoreDataViewController {
    
    var userId: String?
    var navigationHeaderView: NavigationTableHeaderView = {
        return UINib(nibName: "NavigationTableHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! NavigationTableHeaderView
    }()
}


extension BaseProfileDetailsViewController {
    
    override func tableView(_ tableView: UITableView,
                            heightForHeaderInSection section: Int) -> CGFloat {
        return 66
    }
    
    override func tableView(_ tableView: UITableView,
                            viewForHeaderInSection section: Int) -> UIView? {
        
        navigationHeaderView.hideTitle()
        navigationHeaderView.closeActionHandler = { [unowned self] in
            self.dismiss(animated: true, completion: nil)
        }
        return navigationHeaderView
    }
    
}
