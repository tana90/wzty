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
        let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [nameSortDescriptor]
        request.fetchLimit = 50
        
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
            destination?.board = board
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
            performSegue(withIdentifier: "showBoardDetails", sender: self)
        } else {
            performSegue(withIdentifier: "showEditBoardSegue", sender: self)
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
