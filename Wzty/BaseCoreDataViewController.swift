//
//  BaseCoreDataViewController.swift
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
//  Created by Tudor Ana on 15/11/2017.
//  Copyright © 2017 Tudor Ana. All rights reserved.
//

import UIKit
import CoreData

class BaseCoreDataViewController: UITableViewController {
    
    var fetchResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    func perform(_ fetchResultsController: NSFetchedResultsController<NSFetchRequestResult>) {
        self.fetchResultsController = fetchResultsController
        do {
            try fetchResultsController.performFetch()
        } catch _ {
            console("Error performing fetch products")
        }
    }
    
    override func didReceiveMemoryWarning() {
        //Remove memory cache
        KingfisherManager.shared.cache.clearMemoryCache()
    }
}

//MARK: - Fetch Results Controller Delegate
extension BaseCoreDataViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        
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
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            self.tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            self.tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
            self.tableView.reloadRows(at: [indexPath!], with: .automatic)
        case .move:
            self.tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
}
