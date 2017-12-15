//
//  BaseListViewController.swift
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
import CoreData

class BaseListViewController: BaseCoreDataViewController {
    
    var targetUserId: String?
    var targetPostId: String?
    var loading: Bool = false
    let statusBarGradient = UIImageView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44))
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIViewPropertyAnimator(duration: 0.2, curve: .easeIn) { [unowned self] in
            self.view.alpha = 1.0
            }.startAnimation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Configure status bar gradient
        statusBarGradient.image = UIImage(named: "gradient")
        navigationController?.view.addSubview(statusBarGradient)
        statusBarGradient.isHidden = true
        
        //Put refresh control
        refreshControl = UIRefreshControl()
        refreshControl?.tintColor = .white
        tableView.addSubview(refreshControl!)
        refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }
    
    @objc func refreshData() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) { [unowned self] in
            self.refreshControl?.endRefreshing()
        }
    }
    
    func loadData(newer: Bool) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        UIViewPropertyAnimator(duration: 0.2, curve: .easeOut) { [unowned self] in
            self.tableView.alpha = 0.1
            }.startAnimation()
        
        
        if segue.identifier == "showUserDetailsSegue" {
            guard let userId = targetUserId else {
                return
            }
            let destinationViewController = segue.destination as! UserDetailsViewController
            destinationViewController.userId = userId
            return
        } 
        
        if segue.identifier == "showReportSegue" {
            guard let postId = targetPostId else {
                return
            }
            let destinationViewController = segue.destination as! ReportViewController
            destinationViewController.postId = postId
            return
        }
    }
}



//MARK: - TableView Delegate & DataSource
extension BaseListViewController {
    
    override func tableView(_ tableView: UITableView, 
                            heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.size.height - 120
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let fetchResultsControllerT = fetchResultsController,
            let sections = fetchResultsControllerT.sections,
            sections.count > 0
            else {
                return 1
        }
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, 
                            numberOfRowsInSection section: Int) -> Int {
        guard let fetchResultsControllerT = fetchResultsController,
            let sections = fetchResultsControllerT.sections,
            sections.count > 0 else { return 0 }
        
        let currentSection = sections[section]
        return currentSection.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, 
                            willDisplay cell: UITableViewCell, 
                            forRowAt indexPath: IndexPath) {
        guard let fetchResultsControllerT = fetchResultsController,
            let fetchedObjects = fetchResultsControllerT.fetchedObjects else {
                return
        }
        
        let last = fetchedObjects.count - 1
        if !loading && indexPath.row == last {
            //Load more
            loadData(newer: false)
        }
    }
    
    override func tableView(_ tableView: UITableView, 
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsfeedCell") as! NewsfeedCell
        
        cell.showMoreActionsHandler = { [unowned self] (postId) in
            let alertViewController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let reportIssueAction = UIAlertAction(title: "Report issue", style: .default) { [unowned self] (alert) in
                self.targetPostId = postId
                self.performSegue(withIdentifier: "showReportSegue", sender: self)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
            }
            
            alertViewController.addAction(reportIssueAction)
            alertViewController.addAction(cancelAction)
            self.present(alertViewController, animated: true, completion: nil)
        }
        
        return cell
    }
}


//MARK: - ScrollViewDelegate
extension BaseListViewController {
    
    override func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard let navigationController = navigationController else { return }
        
        if navigationController.isNavigationBarHidden {
            statusBarGradient.isHidden = false
        } else {
            statusBarGradient.isHidden = true
        }
        
        if !(navigationController.hidesBarsOnSwipe) {
            if #available(iOS 11.0, *) {
                if scrollView.contentOffset.y > 0 {
                    navigationController.navigationBar.prefersLargeTitles = false
                } else {
                    navigationController.navigationBar.prefersLargeTitles = true
                }
            }
        }
    }
}
