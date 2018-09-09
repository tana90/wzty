//
//  BaseCollectionViewController.swift
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
//  Created by Tudor Ana on 3/25/18.
//  Copyright © 2018 Tudor Ana. All rights reserved.
//

import UIKit
import CoreData

class BaseCollectionViewController: UICollectionViewController {
    
    var fetchResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    var blockOperations: [BlockOperation] = []
    
    let sectionInsets = UIEdgeInsets(top: 10, left: 10.0, bottom: 10.0, right: 10.0)
    let sectionLineInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    var itemsPerRow: CGFloat = 3
    
    deinit {
        for operation: BlockOperation in blockOperations {
            operation.cancel()
        }
        blockOperations.removeAll(keepingCapacity: false)
    }
    
    func perform(_ fetchResultsController: NSFetchedResultsController<NSFetchRequestResult>) {
        self.fetchResultsController = fetchResultsController
        do {
            try fetchResultsController.performFetch()
        } catch _ {
            console("Error performing fetch products")
        }
    }
    
    func scrollToTop() {
        collectionView?.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
    }
}


extension BaseCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding = sectionInsets.left * (itemsPerRow + 1)
        let width = (collectionView.frame.width - padding) / itemsPerRow
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

extension BaseCollectionViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let _ = fetchResultsController?.sections else {
            return 0
        }
        return (fetchResultsController?.sections!.count)!
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let _ = fetchResultsController?.sections else {
            return 0
        }
        return (fetchResultsController?.sections![section].numberOfObjects)!
    }
}


extension BaseCollectionViewController: NSFetchedResultsControllerDelegate {
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            blockOperations.append(BlockOperation(block: { [weak self] in
                guard let _ = self else { return }
                self!.collectionView?.insertItems(at: [newIndexPath!])
            }))
        case .update:
            blockOperations.append(BlockOperation(block: { [weak self] in
                guard let _ = self else { return }
                self!.collectionView?.reloadItems(at: [indexPath!])
            }))
        case .move:
            blockOperations.append(BlockOperation(block: { [weak self] in
                guard let _ = self else { return }
                self!.collectionView?.moveItem(at: indexPath!, to: newIndexPath!)
            }))
        case .delete:
            blockOperations.append(BlockOperation(block: { [weak self] in
                guard let _ = self else { return }
                self!.collectionView?.deleteItems(at: [indexPath!])
            }))
        }
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                           didChange sectionInfo: NSFetchedResultsSectionInfo,
                           atSectionIndex sectionIndex: Int,
                           for type: NSFetchedResultsChangeType) {
        
        switch type {
        case .insert:
            blockOperations.append(BlockOperation(block: { [weak self] in
                guard let _ = self else { return }
                self!.collectionView?.insertSections(IndexSet([sectionIndex]))
            }))
        case .delete:
            blockOperations.append(BlockOperation(block: { [weak self] in
                guard let _ = self else { return }
                self!.collectionView?.deleteSections(IndexSet([sectionIndex]))
            }))
        case .move:
            break
        case .update:
            blockOperations.append(BlockOperation(block: { [weak self] in
                guard let _ = self else { return }
                self!.collectionView?.reloadSections(IndexSet([sectionIndex]))
            }))
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.collectionView?.performBatchUpdates({ [weak self] in
            guard let _ = self else { return }
            for operation in self!.blockOperations {
                operation.start()
            }
        }, completion: { [weak self] (finished) in
            guard let _ = self else { return }
            self!.blockOperations.removeAll(keepingCapacity: false)
        })
    }
}
