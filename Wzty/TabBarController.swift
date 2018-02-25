//
//  TabbarController.swift
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
//  Created by Tudor Ana on 13/11/2017.
//  Copyright © 2017 Tudor Ana. All rights reserved.
//

import UIKit

final class TabBarController: UITabBarController {
    
    var previousViewController: BaseTableViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        if let _ = viewControllers,
            let navigationController = viewControllers![0] as? UINavigationController,
            let rootViewController = navigationController.viewControllers[0] as? BaseTableViewController {
            previousViewController = rootViewController
        }
    }
}

extension TabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        if let navigationController = viewController as? UINavigationController,
            let rootViewController = navigationController.viewControllers[0] as? BaseTableViewController {
            
            if let _ = previousViewController, 
                previousViewController == rootViewController {
                rootViewController.scrollToTop()
            }
            previousViewController = rootViewController
        }
    }
}
