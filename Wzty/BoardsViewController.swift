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
            let destination = segue.destination as? AddNewBoardViewController
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

        if text.count > 0 {
            let predicate = NSPredicate(format: "name CONTAINS[cd] %@", text)
            boardsFetchedResultsController.fetchRequest.predicate = predicate
            do {
                try boardsFetchedResultsController.performFetch()
                
            } catch {
                console("Error perform fetch")
            }
            tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
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

extension BoardsViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
        searchBar.showsCancelButton = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 0 {
            search(searchText)
        } else { clear() }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        guard let _ = searchBar.text else { return }
        search(searchBar.text!)
        searchBar.showsCancelButton = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}


//MARK: - TableView Delegate & DataSource
extension BoardsViewController {
    
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
