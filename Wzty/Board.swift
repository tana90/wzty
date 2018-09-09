//
//  Board.swift
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
//  Created by Tudor Ana on 17/01/2018.
//  Copyright © 2018 Tudor Ana. All rights reserved.
//

import Foundation
import CoreData

final class Board: NSManagedObject {
    
    @NSManaged var objectId: String?
    @NSManaged var name: String?
    @NSManaged var color: String?
    @NSManaged var priority: NSNumber?
    
    //Delete board
    func delete() {
        
        let predicate = NSPredicate(format: "boardId == %@ AND following == true", objectId!)
        User.fetchAllBy(predicate: predicate) { (users) in
            
            if let _ = users {
                for user in users! {
                    user?.boardId = nil
                }
            }
            CoreDataManager.shared.delete(object: self)
        }
    }
    
    //Edit users of a board
    func edit(_ userIds: [String], _ finished: @escaping () -> ()) {
        
        let predicate = NSPredicate(format: "boardId == %@ AND following == true", objectId!)
        User.fetchAllBy(predicate: predicate) { (users) in
            
            //Remove old users from board
            if let _ = users {
                for user in users! {
                    user?.boardId = nil
                }
            }
            
            //Put new users to board
            var count = 0
            for userId in userIds {
                User.fetchBy(id: userId, result: { [weak self] (object) in
                    (object as? User)?.boardId = self?.objectId
                    count += 1
                    if count >= userIds.count {
                        finished()
                    }
                })
            }
        }
    }
}

extension Board {
    
    //Fetch board by id
    static func fetchBy(id: String,
                        result: (NSManagedObject?) -> (Void)) {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Board")
        let predicate = NSPredicate(format: "objectId == %@", id)
        request.predicate = predicate
        request.fetchLimit = 1
        request.fetchBatchSize = 1
        CoreDataManager.shared.backgroundContext.performAndWait {
            do {
                let results = try CoreDataManager.shared.backgroundContext.fetch(request) as? [NSManagedObject]
                guard let last = results?.last else {
                    result(nil)
                    return
                }
                result(last)
            } catch _ {
                console("Error fetching object by id.")
                result(nil)
            }
        }
    }

    
    //Add a board for users
    static func add(_ name: String, _ userIds: [String]) {
        
        if let newObject = NSEntityDescription.insertNewObject(forEntityName: "Board", into: CoreDataManager.shared.backgroundContext) as? Board {
            newObject.objectId = NSUUID().uuidString
            newObject.color = "#353535"
            newObject.name = name
            for userId in userIds {
                User.fetchBy(id: userId, result: { (user) -> (Void) in
                    (user as? User)?.boardId = newObject.objectId
                })
            }
            CoreDataManager.shared.saveContextBackground()
        }
    }
    
    static func count(result: (Int) -> (Void)) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Board")
        CoreDataManager.shared.backgroundContext.performAndWait {
            do {
                let results = try CoreDataManager.shared.backgroundContext.count(for: request)
                result(results)
            } catch _ {
                console("Error fetching object by id.")
                result(0)
            }
        }
    }
}
