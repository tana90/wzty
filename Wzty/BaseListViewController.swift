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
    
    var loading: Bool = false
    
    //Set header view for list *simple text*
    var infoHeaderView: UserDetailsHeaderView = {
        return UINib(nibName: "UserDetailsHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UserDetailsHeaderView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Put refresh control
        refreshControl = UIRefreshControl()
        refreshControl?.tintColor = .white
        tableView.addSubview(refreshControl!)
        refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        //Register for force touch
        if (traitCollection.forceTouchCapability == .available) {
            registerForPreviewing(with: self, sourceView: view)
        }
    }
    
    @objc func refreshData() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) { [weak self] in
            self?.refreshControl?.endRefreshing()
        }
    }
    
    func loadData(newer: Bool) { }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showUserDetailsSegue" {
            guard let _ = targetUserId else {
                return
            }
            let destinationViewController = segue.destination as! UserDetailsViewController
            destinationViewController.userId = targetUserId
            return
        } 
    }
}


//MARK: - TableView Delegate & DataSource
extension BaseListViewController {
    
    override func tableView(_ tableView: UITableView, 
                            heightForRowAt indexPath: IndexPath) -> CGFloat {
        //Setup news cell height
        return max(min(tableView.bounds.size.height - 140, 560), 320)
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
        
        if fetchedObjects.count > 5 {
            let last = fetchedObjects.count - 1
            if !loading && indexPath.row == last {
                //Load more
                loadData(newer: false)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, 
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsfeedCell") as! NewsfeedCell
        
        cell.showMoreActionsHandler = { [weak self] (postId) in
            guard let _ = self else { return }
            let predicate = NSPredicate(format: "objectId == %@", postId)
            Post.fetchBy(predicate, result: { (post) -> (Void) in
                moreAction(post: post, presentedIn: self!)
            })
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


//MARK: - SearchBarDelegate
extension BaseListViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
        searchBar.showsCancelButton = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) { }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}


//MARK: - Force touch preview
extension BaseListViewController: UIViewControllerPreviewingDelegate {
    
    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        if let indexPath = tableView.indexPathForRow(at: location) {
            previewingContext.sourceRect = tableView.rectForRow(at: indexPath)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let destinationViewController = storyboard.instantiateViewController(withIdentifier: "newsfeedDetailsViewController") as? NewsfeedDetailsViewController,
                let post = fetchResultsController?.object(at: indexPath) as? Post
                else { return nil }
            destinationViewController.post = post
            
            return destinationViewController
        }
        return nil
    }
    
    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        showDetailViewController(viewControllerToCommit, sender: self)
    }
}
