//
//  BoardsViewController.swift
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
//  Created by Tudor Ana on 15/01/2018.
//  Copyright © 2018 Tudor Ana. All rights reserved.
//

import UIKit
import CoreData

final class BoardsViewController: BaseListViewController {
    
    lazy var boardsFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Board")
        let prioritySortDescriptor = NSSortDescriptor(key: "priority", ascending: false)
        let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [prioritySortDescriptor, nameSortDescriptor]
        request.fetchBatchSize = FETCH_REQUEST_BATCH_SIZE
        
        let frc = NSFetchedResultsController(fetchRequest: request,
                                             managedObjectContext: CoreDataManager.shared.backgroundContext,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    
    @IBAction func editAction() {
        isEditing = !isEditing
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Configure cell
        tableView.register(UINib(nibName: "BoardCell", bundle: nil), forCellReuseIdentifier: "boardCell")
        
        //Register for CoreData updates
        perform(boardsFetchedResultsController)
        
        //Show search bar
        searchController.searchBar.delegate = self
        self.navigationItem.searchController = searchController
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "showBoardDetails" {
            let destination = segue.destination as? BoardDetailsViewController
            guard let board = boardsFetchedResultsController.object(at: tableView.indexPathForSelectedRow!) as? Board else {
                return
            }
            board.priority = NSNumber(value: (board.priority?.intValue)! + 1)
            CoreDataManager.shared.saveContextBackground()
            destination?.board = board
            scrollToTop()
            return
        }
        
        if segue.identifier == "showEditBoardSegue" { 
            let destination = segue.destination as? SelectUsersViewController
            guard let board = boardsFetchedResultsController.object(at: tableView.indexPathForSelectedRow!) as? Board else {
                return
            }
            destination?.boardName = board.name
            destination?.boardId = board.objectId
            let predicate = NSPredicate(format: "boardId == %@", board.objectId!)
            var usersIds: [String] = []
            User.fetchAllBy(predicate: predicate) { (users) in
                if let _ = users {
                    for user in users! {
                        usersIds.append((user?.objectId!)!)
                    }
                    destination?.selectedUsers = usersIds
                }
            }
            return
        }
    }
}


extension BoardsViewController {
    
    func search(_ text: String) {
        
        let predicate = NSPredicate(format: "name CONTAINS[cd] %@", text)
        boardsFetchedResultsController.fetchRequest.predicate = predicate
        do {
            try boardsFetchedResultsController.performFetch()
            
        } catch {
            console("Error perform fetch")
        }
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
    
    func clear() {
        boardsFetchedResultsController.fetchRequest.predicate = nil
        do {
            try boardsFetchedResultsController.performFetch()
            
        } catch {
            console("Error perform fetch")
        }
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
}

extension BoardsViewController {
    
    override func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 0 {
            search(searchText)
        } else { clear() }
    }
}


//MARK: - TableView Delegate & DataSource
extension BoardsViewController {
    
    override func tableView(_ tableView: UITableView,
                            viewForHeaderInSection section: Int) -> UIView? {
        Board.count { (count) in
            infoHeaderView.show((count > 0) ? String(format: "%ld boards", count) : nil)
        }
        return infoHeaderView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 44
    }
    
    override func tableView(_ tableView: UITableView, 
                            heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 135
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "boardCell") as? BoardCell
        guard let board = boardsFetchedResultsController.object(at: indexPath) as? Board else {
            return cell!
        }
        cell!.show(board)
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        if !isEditing {
            self.performSegue(withIdentifier: "showBoardDetails", sender: self)
        } else {
            self.performSegue(withIdentifier: "showEditBoardSegue", sender: self)
        }
        
        isEditing = false
    }
    
    override func tableView(_ tableView: UITableView, 
                            commit editingStyle: UITableViewCellEditingStyle, 
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let board = boardsFetchedResultsController.object(at: indexPath) as? Board else {
                return
            }
            board.delete()
        }
    }
}
