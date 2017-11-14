//
//  BaseDetailsViewController.swift
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

class BaseDetailsViewController: UITableViewController {
    
    var post: Post?
    var navigationHeaderView: NavigationTableHeaderView = {
        return UINib(nibName: "NavigationTableHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! NavigationTableHeaderView
    }()
    
    override func viewDidLoad() {
        
        tableView.register(UINib(nibName: "NewsfeedDetailsCell", bundle: nil), forCellReuseIdentifier: "newsfeedDetailsCell")
        tableView.register(UINib(nibName: "NewsfeedWebCell", bundle: nil), forCellReuseIdentifier: "newsfeedWebCell")
    }
}

extension BaseDetailsViewController {
    
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
    
    override func tableView(_ tableView: UITableView,
                            estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 660
    }
    
    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return UITableViewAutomaticDimension
        }
        return UIScreen.main.bounds.size.height - 66
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {        
        return UITableViewCell()
    }
}


extension BaseDetailsViewController {
    
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y < -88 {
            dismiss(animated: true, completion: nil)
        }
        
        if let detailsCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) {
            if scrollView.contentOffset.y >= detailsCell.bounds.size.height {
                //Stop scrolling
                scrollView.isScrollEnabled = false
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.05, execute: {
                    scrollView.isScrollEnabled = true
                })
                navigationHeaderView.showTitle()
            } else {
                navigationHeaderView.hideTitle()
            }
        }
        
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                            withVelocity velocity: CGPoint,
                                            targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if let detailsCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) {
            
            if scrollView.contentOffset.y > (detailsCell.bounds.size.height / 2) + 44 {
                tableView.scrollToRow(at: IndexPath(row: 1, section: 0), at: .top, animated: true)
                navigationHeaderView.showTitle()
            } else {
                tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                navigationHeaderView.hideTitle()
            }
        }

    }
}

