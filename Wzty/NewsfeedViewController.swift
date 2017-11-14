//
//  NewsfeedViewController.swift
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

final class NewsfeedViewController: BaseListViewController {
    
    lazy var postFetchResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Post")
        let timeSortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
        request.sortDescriptors = [timeSortDescriptor]
        request.fetchLimit = 100
        
        let frc = NSFetchedResultsController(fetchRequest: request,
                                             managedObjectContext: CoreDataManager.shared.backgroundContext,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Add a fake status bar
        let statusBarView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 22))
        statusBarView.backgroundColor = .white
        navigationController?.view.addSubview(statusBarView)
        
        //Configure cell
        tableView.register(UINib(nibName: "NewsfeedCell", bundle: nil), forCellReuseIdentifier: "newsfeedCell")
        tableView.estimatedRowHeight = 600
        
        
        //Register for CoreData updates
        perform(postFetchResultsController)
        
        //Load first posts
        loadData(newer: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @objc override func refreshData() {
        super.refreshData()
        //Reload posts
        loadData(newer: true)
    }
    
    override func loadData(newer: Bool) {
        loading = true
        User.current { (user) in
            Post.homeTimeline(sinceId: newer ? user?.sinceId : nil,
                              maxId: newer ? nil : user?.maxId) { [unowned self] (posts) in
                                self.loading = false
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showNewsDetailsSegue" {
            let destination = segue.destination as? NewsfeedDetailsViewController
            guard let post = postFetchResultsController.object(at: tableView.indexPathForSelectedRow!) as? Post else {
                return
            }
            destination?.post = post
        }
    }
}


//MARK: - TableView Delegate & DataSource
extension NewsfeedViewController {
    
    override func tableView(_ tableView: UITableView,
                            heightForHeaderInSection section: Int) -> CGFloat {
        return 52
    }

    override func tableView(_ tableView: UITableView,
                            viewForHeaderInSection section: Int) -> UIView? {

        let headerView = UINib(nibName: "NewsfeedHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0]
        return headerView as? UIView
    }
    
    override func tableView(_ tableView: UITableView,
                            willDisplay cell: UITableViewCell,
                            forRowAt indexPath: IndexPath) {
        
        super.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
        
        //Prepare image
        guard let post = postFetchResultsController.object(at: indexPath) as? Post else { return }
        (cell as! NewsfeedCell).prefetch(post)
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath) as! NewsfeedCell
        guard let post = postFetchResultsController.object(at: indexPath) as? Post else {
            return cell
        }
        cell.show(post)
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "showNewsDetailsSegue", sender: self)
    }
}


//MARK: - TableView Prefetch DataSource
extension NewsfeedViewController {
    
    override func tableView(_ tableView: UITableView,
                            prefetchRowsAt indexPaths: [IndexPath]) {
        
        for indexPath in indexPaths {
            
            guard let post = postFetchResultsController.object(at: indexPath) as? Post else {
                return
            }
            
            if post.title == nil {
                URL(string: post.url!)!.fetchUrlMedia({ (title, details, image) in
                    
                    guard let titleT = title else {
                        CoreDataManager.shared.delete(object: post)
                        CoreDataManager.shared.saveContextBackground()
                        return
                    }
                    
                    post.title = titleT
                    post.details = details
                    post.imageUrl = image
                    
                    //Prepare image
                    guard let imageUrlT = post.imageUrl else { return }
                    let tempImg = UIImageView()
                    tempImg.kf.setImage(with: URL(string: imageUrlT))
                    
                }, failure: { (error) in
                    print("Error \(error)")
                    CoreDataManager.shared.delete(object: post)
                    CoreDataManager.shared.saveContextBackground()
                })
            }
        }
    }
}
