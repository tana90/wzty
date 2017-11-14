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

class BaseListViewController: UITableViewController {
    
    var fetchResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    var loading: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Put refresh control
        refreshControl = UIRefreshControl()
        tableView.addSubview(refreshControl!)
        refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }
    
    func perform(_ fetchResultsController: NSFetchedResultsController<NSFetchRequestResult>) {
        
        self.fetchResultsController = fetchResultsController
        do {
            try fetchResultsController.performFetch()
        } catch _ {
            print("Error performing fetch products")
        }
    }
    
    @objc func refreshData() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) { [unowned self] in
            self.refreshControl?.endRefreshing()
        }
    }

    func loadData(newer: Bool) {
    }
    
}


//MARK: - TableView Delegate & DataSource
extension BaseListViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let fetchResultsControllerT = fetchResultsController,
            let sections = fetchResultsControllerT.sections,
            sections.count > 0 else { return 0 }
        
        let currentSection = sections[section]
        return currentSection.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsfeedCell") as! NewsfeedCell
        return cell
    }
}


extension BaseListViewController: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        //
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        //
    }
}



//MARK: - Fetch Results Controller Delegate
extension BaseListViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        switch type {
        case .insert:
            self.tableView.insertSections(IndexSet([sectionIndex]), with: .automatic)
        case .delete:
            self.tableView.deleteSections(IndexSet([sectionIndex]), with: .automatic)
        case .move:
            break
        case .update:
            self.tableView.reloadSections(IndexSet([sectionIndex]), with: .automatic)
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            self.tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            self.tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
            if (tableView.indexPathsForVisibleRows?.contains(indexPath!))! {
                self.tableView.reloadRows(at: [indexPath!], with: .automatic)
            }
        case .move:
            self.tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
}
