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

final class BoardsViewController: BaseCollectionViewController {
    
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

    override func viewDidLoad() {
        super.viewDidLoad()

        itemsPerRow = 2
        
        //Register cell
        collectionView?.register(UINib(nibName: "BoardCell", bundle: nil), 
                                 forCellWithReuseIdentifier: "boardCell")

        //Register for CoreData updates
        perform(boardsFetchedResultsController)
        
        //Register long press action for edit and delete board
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(BoardsViewController.handleLongPress))
        collectionView?.addGestureRecognizer(longPressGesture)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "showBoardDetails" {
            let destination = segue.destination as? BoardDetailsViewController
            guard let board = boardsFetchedResultsController.object(at:
                (collectionView?.indexPathsForSelectedItems![0])!) as? Board else {
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
            guard let board = boardsFetchedResultsController.object(at:
                (collectionView?.indexPathsForSelectedItems![0])!) as? Board else {
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
    
    
    @objc func handleLongPress(gesture : UILongPressGestureRecognizer!) {
        let p = gesture.location(in: self.collectionView)
        if let indexPath = self.collectionView?.indexPathForItem(at: p) {
            guard let board = boardsFetchedResultsController.object(at: indexPath) as? Board else {
                return
            }
            editBoardAction(board, at: indexPath, presentedIn: self)
        }
    }
}


extension BoardsViewController {
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "boardCell", for: indexPath) as! BoardCell
        guard let board = boardsFetchedResultsController.object(at: indexPath) as? Board else {
            return cell
        }
        cell.show(board, at: indexPath.row)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showBoardDetails", sender: self)
    }
}
